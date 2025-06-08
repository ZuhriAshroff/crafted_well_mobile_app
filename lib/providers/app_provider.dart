// lib/providers/app_provider.dart
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  // Static sample products (always available)
  List<Product> _localProducts = Product.sampleProducts;

  // API products (online only)
  List<Product> _railwayProducts = [];
  List<Product> _customProducts = [];

  // Offline JSON products (fallback when offline)
  List<Product> _offlineProducts = [];

  // External makeup API data (relevant external source)
  List<Map<String, dynamic>> _externalMakeupData = [];

  // Device capabilities
  bool _isOnline = true;
  Position? _location;
  int _batteryLevel = 0;
  bool _isLoading = false;

  // Database
  Database? _database;

  // Auth integration
  bool _isUserLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  // SMART GETTERS: Different logic for online vs offline
  List<Product> get allProducts {
    if (_isOnline && _isUserLoggedIn) {
      // ONLINE + LOGGED IN: Show API products (personalized)
      return [..._railwayProducts, ..._customProducts, ..._localProducts];
    } else if (_isOnline && !_isUserLoggedIn) {
      // ONLINE + NOT LOGGED IN: Show API products + local (no custom)
      return [..._railwayProducts, ..._localProducts];
    } else {
      // OFFLINE: Show offline JSON + local products only
      return [..._offlineProducts, ..._localProducts];
    }
  }

  // Individual getters for assignment demonstration
  List<Product> get localProducts => _localProducts;
  List<Product> get railwayProducts => _railwayProducts;
  List<Product> get offlineProducts => _offlineProducts;
  List<Product> get customProducts => _customProducts;
  List<Map<String, dynamic>> get externalMakeupData => _externalMakeupData;

  // Status getters
  bool get isOnline => _isOnline;
  Position? get location => _location;
  int get batteryLevel => _batteryLevel;
  bool get isLoading => _isLoading;
  bool get isUserLoggedIn => _isUserLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;

  // NEW: Check if user can access personalized content
  bool get canAccessPersonalizedContent => _isOnline && _isUserLoggedIn;

  // NEW: Check if offline mode (for UI messaging)
  bool get isOfflineMode => !_isOnline;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize auth state first
      await _initializeAuthState();

      // Initialize device capabilities
      await _initDatabase();
      await _monitorConnectivity();
      await _loadDeviceCapabilities();

      // Load data based on connectivity
      if (_isOnline) {
        await _loadOnlineData();
      } else {
        await _loadOfflineData();
      }

      print('✅ App initialization complete');
    } catch (e) {
      print('❌ App initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load data when online
  Future<void> _loadOnlineData() async {
    await Future.wait([
      loadRailwayData(),
      loadExternalMakeupData(), // Changed from JSONPlaceholder
      loadCustomProducts(),
      loadLocalJsonData(), // Always load as fallback
    ]);
  }

  // Load data when offline
  Future<void> _loadOfflineData() async {
    await loadLocalJsonData(); // Load offline JSON products
    print('📴 Offline mode: Loaded local JSON products only');
  }

  // Initialize auth state
  Future<void> _initializeAuthState() async {
    try {
      _isUserLoggedIn = await AuthService.isLoggedIn();
      if (_isUserLoggedIn) {
        _currentUser = await AuthService.getUser();
        print('✅ User restored: ${_currentUser?['email']}');
      }
    } catch (e) {
      print('⚠️ Auth state initialization error: $e');
    }
  }

  // Update auth state (call this after login/logout)
  Future<void> updateAuthState() async {
    try {
      _isUserLoggedIn = UserManager.isLoggedIn;
      _currentUser = UserManager.currentUser;

      print('🔄 AppProvider: Auth state synced - isLoggedIn: $_isUserLoggedIn');
      if (_isUserLoggedIn && _isOnline) {
        // Load custom products when user logs in
        await loadCustomProducts();
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ AppProvider: Auth sync error - $e');
    }
  }

  // Monitor connectivity with smart data loading
  Future<void> _monitorConnectivity() async {
    try {
      final connectivity = Connectivity();

      // Check initial connectivity
      final result = await connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      // Listen for changes
      connectivity.onConnectivityChanged.listen((result) async {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        print('📡 Connectivity changed: $_isOnline');

        if (!wasOnline && _isOnline) {
          // Just came back online - load online data
          print('🔄 Back online - loading API data');
          await _loadOnlineData();
        } else if (wasOnline && !_isOnline) {
          // Just went offline - ensure offline data is loaded
          print('📴 Gone offline - switching to local data');
          await _loadOfflineData();
        }

        notifyListeners();
      });

      print('✅ Connectivity monitoring initialized: $_isOnline');
    } catch (e) {
      print('❌ Connectivity error: $e');
    }
  }

  // Device capabilities (assignment requirement)
  Future<void> _loadDeviceCapabilities() async {
    try {
      // GPS Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          _location = await Geolocator.getCurrentPosition();
          print('✅ GPS location acquired');
        }
      }

      // Battery Level
      final battery = Battery();
      _batteryLevel = await battery.batteryLevel;

      // Listen for battery changes
      battery.onBatteryStateChanged.listen((state) async {
        final newLevel = await battery.batteryLevel;
        if (newLevel != _batteryLevel) {
          _batteryLevel = newLevel;
          notifyListeners();
        }
      });

      print('✅ Battery monitoring initialized: $_batteryLevel%');
      notifyListeners();
    } catch (e) {
      print('❌ Device capabilities error: $e');
    }
  }

  // SQLite Database (assignment requirement)
  Future<void> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'crafted_well.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE cached_products(id TEXT PRIMARY KEY, name TEXT, description TEXT, price REAL, created_at TEXT)',
          );
          await db.execute(
            'CREATE TABLE survey_responses(id INTEGER PRIMARY KEY AUTOINCREMENT, skin_type TEXT, concerns TEXT, environment TEXT, created_at TEXT)',
          );
          print('✅ Database tables created');
        },
      );

      print('✅ SQLite database initialized');
    } catch (e) {
      print('❌ Database initialization error: $e');
    }
  }

  // Railway API integration (assignment requirement)
  Future<void> loadRailwayData() async {
    if (!_isOnline) {
      print('📴 Offline - skipping Railway API');
      _railwayProducts = [];
      return;
    }

    try {
      final token = await AuthService.getToken();
      final headers = {'Accept': 'application/json'};

      if (token != null && !token.startsWith('demo_')) {
        headers['Authorization'] = 'Bearer $token';
        print('💰 Using authenticated Railway API call');
      } else {
        print('💡 Using public Railway API call (demo mode)');
      }

      final response = await http
          .get(
            Uri.parse(
                'https://crafted-well-laravel.up.railway.app/api/products'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];

          _railwayProducts = productsJson
              .map((json) => Product(
                    id: json['product_id']?.toString() ?? '0',
                    name: json['product_name'] ?? 'Unknown Product',
                    description:
                        json['base_category'] ?? 'Custom skincare formulation',
                    ingredients: 'Professional formulation ingredients',
                    usage: 'Apply as directed for your skin type',
                    price: double.tryParse(
                            json['standard_price']?.toString() ?? '0') ??
                        0.0,
                    imageAsset: 'assets/images/product-image-1.png',
                    benefits: [
                      'Custom formulation',
                      'Professional grade',
                      'Skin type specific'
                    ],
                  ))
              .toList();

          await _cacheProducts(_railwayProducts);
          print('✅ Railway API loaded: ${_railwayProducts.length} products');
        }
      } else {
        print('⚠️ Railway API returned status: ${response.statusCode}');
        _railwayProducts = await _loadCachedProducts();
      }
    } catch (e) {
      print('❌ Railway API error: $e');
      _railwayProducts = await _loadCachedProducts();
    }
    notifyListeners();
  }

  // NEW: External Makeup API data (relevant to skincare/beauty)
  Future<void> loadExternalMakeupData() async {
    if (!_isOnline) {
      print('📴 Offline - skipping external makeup API');
      return;
    }

    try {
      final response = await http
          .get(Uri.parse(
              'http://makeup-api.herokuapp.com/api/v1/products.json?product_type=foundation&brand=maybelline'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Take only first 6 products
        _externalMakeupData = data
            .take(6)
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'] ?? 'Unknown Product',
                  'brand': item['brand'] ?? 'Unknown Brand',
                  'price': item['price'] ?? '0.0',
                  'category': item['category'] ?? 'Makeup',
                  'product_type': item['product_type'] ?? 'Foundation',
                })
            .toList();

        print(
            '✅ External makeup API loaded: ${_externalMakeupData.length} items');
        notifyListeners();
      }
    } catch (e) {
      print('❌ External makeup API error: $e');
    }
  }

  // FIXED: Custom Products API integration (use actual API response names)
  Future<void> loadCustomProducts() async {
    if (!_isUserLoggedIn) {
      print('🔐 Not logged in - skipping custom products');
      _customProducts = [];
      return;
    }

    final token = await AuthService.getToken();

    if (token == null || token.startsWith('demo_')) {
      print('💡 Demo mode - creating sample custom products');
      await _createDemoCustomProducts();
      return;
    }

    if (!_isOnline) {
      print('📴 Offline - skipping custom products API');
      return;
    }

    try {
      print('💰 Loading custom products from SSP API');

      final response = await http.get(
        Uri.parse(
            'https://crafted-well-laravel.up.railway.app/api/custom-products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> customProductsJson = data['data'];

          _customProducts = customProductsJson
              .map((json) => Product(
                    id: 'custom_${json['id']}',
                    // FIXED: Use actual API response name
                    name: json['name'] ??
                        json['product_name'] ??
                        'Custom Product',
                    description:
                        json['description'] ?? 'Custom formulated product',
                    ingredients: json['ingredients'] is List
                        ? (json['ingredients'] as List).join(', ')
                        : json['ingredients']?.toString() ??
                            'Custom ingredients',
                    usage:
                        json['usage'] ?? 'Apply as directed for your skin type',
                    price: double.tryParse(json['price']?.toString() ?? '0') ??
                        59.99,
                    imageAsset: 'assets/images/product-image-1.png',
                    benefits: [
                      'Custom formulated',
                      'Based on your survey',
                      'Personalized for your skin'
                    ],
                  ))
              .toList();

          print('✅ Custom products loaded: ${_customProducts.length} products');
        } else {
          print('⚠️ No custom products found - creating one');
          await _createCustomProduct(token);
        }
      } else if (response.statusCode == 401) {
        print('🔐 Authentication required for custom products');
      } else {
        print('⚠️ Custom products API returned: ${response.statusCode}');
        await _createDemoCustomProducts();
      }
    } catch (e) {
      print('❌ Custom products API error: $e');
      await _createDemoCustomProducts();
    }
    notifyListeners();
  }

  // Create a custom product via API
  Future<void> _createCustomProduct(String token) async {
    try {
      print('🎨 Creating custom product via SSP API');

      final response = await http
          .post(
            Uri.parse(
                'https://crafted-well-laravel.up.railway.app/api/custom-products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'name': 'Your Personalized Serum',
              'description':
                  'Custom serum formulated based on your survey responses',
              'base_formulation_id': 1,
              'custom_ingredients': [
                {'ingredient_id': 1, 'amount': 5.0},
                {'ingredient_id': 2, 'amount': 3.0},
              ],
              'skin_concerns': ['hydration', 'anti-aging'],
              'skin_type': 'combination',
              'price': 79.99,
            }),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Custom product created via API');

        // Add the newly created product with actual API response name
        final customProduct = Product(
          id: 'custom_${data['data']['id']}',
          name: data['data']['name'] ??
              data['data']['product_name'] ??
              'Your Personalized Serum',
          description:
              data['data']['description'] ?? 'Custom formulated product',
          ingredients: 'Hyaluronic Acid, Niacinamide, Vitamin C',
          usage: 'Apply 2-3 drops to clean skin morning and evening',
          price: data['data']['price']?.toDouble() ?? 79.99,
          imageAsset: 'assets/images/product-image-2.png',
          benefits: [
            'Custom formulated for you',
            'Based on your survey answers',
            'Targets your specific concerns'
          ],
        );

        _customProducts.add(customProduct);
        print('✅ Custom product added to list');
      } else {
        print('⚠️ Custom product creation failed: ${response.statusCode}');
        await _createDemoCustomProducts();
      }
    } catch (e) {
      print('❌ Custom product creation error: $e');
      await _createDemoCustomProducts();
    }
  }

  // Create demo custom products for demo mode
  Future<void> _createDemoCustomProducts() async {
    _customProducts = [
      Product(
        id: 'custom_demo_1',
        name: 'Your Personalized Hydra-Glow Serum',
        description:
            'Custom serum formulated based on your survey: combination skin with hydration concerns',
        ingredients:
            'Hyaluronic Acid (5%), Niacinamide (3%), Vitamin C (2%), Ceramides',
        usage:
            'Apply 2-3 drops to clean skin morning and evening. Follow with moisturizer.',
        price: 79.99,
        imageAsset: 'assets/images/product-image-2.png',
        benefits: [
          'Formulated for your combination skin',
          'Targets hydration and texture',
          'Based on your survey responses',
          'Clinically tested ingredients'
        ],
      ),
    ];

    print('✅ Demo custom products created: ${_customProducts.length} products');
  }

  // Load offline JSON data (fallback when offline)
  Future<void> loadLocalJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> productsJson = jsonData['products'];

      _offlineProducts = productsJson
          .map((json) => Product(
                id: json['id']?.toString() ?? 'offline_unknown',
                name: json['name'] ?? 'Unknown Offline Product',
                description:
                    json['description'] ?? 'Offline product description',
                ingredients: json['ingredients'] ?? 'Natural ingredients',
                usage: json['usage'] ?? 'Apply as needed',
                price: (json['price'] ?? 0.0).toDouble(),
                imageAsset:
                    json['imageAsset'] ?? 'assets/images/product-image-1.png',
                benefits: json['benefits'] != null
                    ? List<String>.from(json['benefits'])
                    : ['Offline availability'],
              ))
          .toList();

      print('✅ Local JSON loaded: ${_offlineProducts.length} products');
      notifyListeners();
    } catch (e) {
      print('❌ Local JSON loading error: $e');
      _offlineProducts = [];
      notifyListeners();
    }
  }

  // Cache and database methods
  Future<void> _cacheProducts(List<Product> products) async {
    if (_database == null) return;

    try {
      for (var product in products) {
        await _database!.insert(
          'cached_products',
          {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('✅ Products cached to SQLite');
    } catch (e) {
      print('❌ Cache products error: $e');
    }
  }

  Future<List<Product>> _loadCachedProducts() async {
    if (_database == null) return [];

    try {
      final List<Map<String, dynamic>> maps =
          await _database!.query('cached_products');

      final cachedProducts = maps
          .map((map) => Product(
                id: map['id'],
                name: map['name'],
                description: map['description'],
                ingredients: 'Cached ingredients',
                usage: 'Cached usage instructions',
                price: map['price'],
                imageAsset: 'assets/images/product-image-1.png',
                benefits: ['Cached product'],
              ))
          .toList();

      print('✅ Loaded ${cachedProducts.length} cached products');
      return cachedProducts;
    } catch (e) {
      print('❌ Load cached products error: $e');
      return [];
    }
  }

  // Save survey data (assignment requirement)
  Future<void> saveSurveyData(
      String skinType, String concerns, String environment) async {
    if (_database == null) return;

    try {
      await _database!.insert('survey_responses', {
        'skin_type': skinType,
        'concerns': concerns,
        'environment': environment,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Survey data saved: $skinType, $concerns, $environment');
    } catch (e) {
      print('❌ Save survey data error: $e');
    }
  }

  // Refresh all data based on current state
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    if (_isOnline) {
      await _loadOnlineData();
    } else {
      await _loadOfflineData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get device info summary for UI display
  String getDeviceStatusSummary() {
    final List<String> status = [];

    if (_batteryLevel > 0) {
      status.add('🔋 ${_batteryLevel}%');
    }

    status.add(_isOnline ? '🌐 Online' : '📴 Offline');

    if (_location != null) {
      status.add('📍 GPS');
    }

    return status.join(' • ');
  }

  // NEW: Get data source context message for UI
  String getDataSourceMessage() {
    if (!_isOnline) {
      return '📴 Offline Mode: Showing cached products';
    } else if (_isUserLoggedIn) {
      return '🌐 Online: Personalized recommendations';
    } else {
      return '🌐 Online: General products (login for personalized)';
    }
  }
}
