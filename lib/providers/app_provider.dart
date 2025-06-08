// lib/providers/app_provider.dart
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _batteryLevel = 100;
  bool _isLoading = false;

  // NEW: Enhanced device impact properties
  bool _powerSavingMode = false;
  String _currentClimate = 'unknown';
  int _apiCallFrequency = 30; // seconds between API calls
  bool _enableHighAccuracyLocation = true;
  List<Product> _climateFilteredProducts = [];

  // Database
  Database? _database;

  // Auth integration
  bool _isUserLoggedIn = false;
  Map<String, dynamic>? _currentUser;

  // ENHANCED: Smart getters with climate filtering
  List<Product> get allProducts {
    List<Product> baseProducts;

    if (_isOnline && _isUserLoggedIn) {
      // ONLINE + LOGGED IN: Show API products (personalized)
      baseProducts = [
        ..._railwayProducts,
        ..._customProducts,
        ..._localProducts
      ];
    } else if (_isOnline && !_isUserLoggedIn) {
      // ONLINE + NOT LOGGED IN: Show API products + local (no custom)
      baseProducts = [..._railwayProducts, ..._localProducts];
    } else {
      // OFFLINE: Show offline JSON + local products only
      baseProducts = [..._offlineProducts, ..._localProducts];
    }

    // CLIMATE FILTERING: Show products based on location/climate
    if (_location != null && _currentClimate != 'unknown') {
      return _filterProductsByClimate(baseProducts);
    }

    return baseProducts;
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

  // NEW: Enhanced getters for meaningful impact
  bool get powerSavingMode => _powerSavingMode;
  String get currentClimate => _currentClimate;
  int get apiCallFrequency => _apiCallFrequency;
  List<Product> get climateFilteredProducts => _climateFilteredProducts;

  // Check if user can access personalized content
  bool get canAccessPersonalizedContent => _isOnline && _isUserLoggedIn;

  // Check if offline mode (for UI messaging)
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

  // NEW: Filter products based on climate
  List<Product> _filterProductsByClimate(List<Product> products) {
    switch (_currentClimate) {
      case 'tropical':
        // Prioritize hydrating, oil-free products for humid climates
        return products
                .where((p) =>
                    p.description.toLowerCase().contains('hydrat') ||
                    p.description.toLowerCase().contains('oil-free') ||
                    p.description.toLowerCase().contains('lightweight') ||
                    p.name.toLowerCase().contains('serum'))
                .toList() +
            products
                .where((p) =>
                    !p.description.toLowerCase().contains('hydrat') &&
                    !p.description.toLowerCase().contains('oil-free') &&
                    !p.name.toLowerCase().contains('serum'))
                .toList();

      case 'dry':
        // Prioritize moisturizing, barrier-repair products
        return products
                .where((p) =>
                    p.description.toLowerCase().contains('moistur') ||
                    p.description.toLowerCase().contains('barrier') ||
                    p.description.toLowerCase().contains('repair') ||
                    p.name.toLowerCase().contains('cream'))
                .toList() +
            products
                .where((p) =>
                    !p.description.toLowerCase().contains('moistur') &&
                    !p.name.toLowerCase().contains('cream'))
                .toList();

      case 'urban':
        // Prioritize anti-pollution, antioxidant products
        return products
                .where((p) =>
                    p.description.toLowerCase().contains('antioxidant') ||
                    p.description.toLowerCase().contains('protect') ||
                    p.description.toLowerCase().contains('pollution') ||
                    p.description.toLowerCase().contains('vitamin c'))
                .toList() +
            products;

      default:
        return products;
    }
  }

  // Load data when online
  Future<void> _loadOnlineData() async {
    await Future.wait([
      loadRailwayData(),
      loadExternalMakeupData(),
      loadCustomProducts(),
      loadLocalJsonData(),
    ]);
  }

  // Load data when offline
  Future<void> _loadOfflineData() async {
    await loadLocalJsonData();
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
          print('🔄 Back online - loading API data');
          await _loadOnlineData();
        } else if (wasOnline && !_isOnline) {
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

  // ENHANCED: Device capabilities with meaningful impact
  Future<void> _loadDeviceCapabilities() async {
    try {
      // GPS Location with climate detection
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          // Use different accuracy based on battery level
          LocationAccuracy accuracy = _batteryLevel > 30
              ? LocationAccuracy.high
              : LocationAccuracy.medium;

          _location = await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
          );

          // Determine climate based on location
          _currentClimate = _determineClimate(_location!);

          print('✅ GPS location acquired: $_currentClimate climate detected');
        }
      }

      // Battery Level with power management
      final battery = Battery();
      _batteryLevel = await battery.batteryLevel;
      _updatePowerSavingMode();

      // Listen for battery changes with impact
      battery.onBatteryStateChanged.listen((state) async {
        final newLevel = await battery.batteryLevel;
        if (newLevel != _batteryLevel) {
          _batteryLevel = newLevel;
          _updatePowerSavingMode();
          _adjustApiFrequency();
          notifyListeners();
        }
      });

      print(
          '✅ Battery monitoring initialized: $_batteryLevel% (Power saving: $_powerSavingMode)');
      notifyListeners();
    } catch (e) {
      print('❌ Device capabilities error: $e');
    }
  }

  // NEW: Determine climate based on coordinates
  String _determineClimate(Position position) {
    final lat = position.latitude;
    final lng = position.longitude;

    // Tropical zone (between 23.5°N and 23.5°S)
    if (lat.abs() <= 23.5) {
      return 'tropical';
    }

    // Desert/dry regions (rough approximation)
    if ((lat >= 20 && lat <= 35) || (lat >= -35 && lat <= -20)) {
      return 'dry';
    }

    // Urban detection (major cities - simplified)
    final majorCities = [
      {'name': 'New York', 'lat': 40.7128, 'lng': -74.0060},
      {'name': 'London', 'lat': 51.5074, 'lng': -0.1278},
      {'name': 'Tokyo', 'lat': 35.6762, 'lng': 139.6503},
      {'name': 'Sydney', 'lat': -33.8688, 'lng': 151.2093},
      {'name': 'Los Angeles', 'lat': 34.0522, 'lng': -118.2437},
      {'name': 'Chicago', 'lat': 41.8781, 'lng': -87.6298},
      {'name': 'Paris', 'lat': 48.8566, 'lng': 2.3522},
      {'name': 'Berlin', 'lat': 52.5200, 'lng': 13.4050},
    ];

    for (final city in majorCities) {
      final distance = Geolocator.distanceBetween(
          lat, lng, city['lat']! as double, city['lng']! as double);
      if (distance < 100000) {
        // Within 100km of major city
        return 'urban';
      }
    }

    // Default to moderate climate
    return 'moderate';
  }

  // NEW: Update power saving mode based on battery
  void _updatePowerSavingMode() {
    final oldMode = _powerSavingMode;
    _powerSavingMode = _batteryLevel <= 20;

    if (oldMode != _powerSavingMode) {
      print(
          '🔋 Power saving mode ${_powerSavingMode ? 'ENABLED' : 'DISABLED'}');
      _adjustApiFrequency();

      if (_powerSavingMode) {
        _enableHighAccuracyLocation = false;
      }
    }
  }

  // NEW: Adjust API call frequency based on battery
  void _adjustApiFrequency() {
    final oldFrequency = _apiCallFrequency;

    if (_batteryLevel <= 10) {
      _apiCallFrequency = 300; // 5 minutes
    } else if (_batteryLevel <= 20) {
      _apiCallFrequency = 120; // 2 minutes
    } else if (_batteryLevel <= 50) {
      _apiCallFrequency = 60; // 1 minute
    } else {
      _apiCallFrequency = 30; // 30 seconds
    }

    if (oldFrequency != _apiCallFrequency) {
      print(
          '📡 API frequency adjusted: ${_apiCallFrequency}s (Battery: $_batteryLevel%)');
    }
  }

  // SQLite Database
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

  // ENHANCED: Railway API with battery-aware frequency
  Future<void> loadRailwayData() async {
    if (!_isOnline) {
      print('📴 Offline - skipping Railway API');
      _railwayProducts = [];
      return;
    }

    // Skip API call if in extreme power saving mode
    if (_batteryLevel <= 5) {
      print('🔋 Extreme power saving - skipping Railway API');
      _railwayProducts = await _loadCachedProducts();
      return;
    }

    try {
      final token = await AuthService.getToken();
      final headers = {'Accept': 'application/json'};

      if (token != null && !token.startsWith('demo_')) {
        headers['Authorization'] = 'Bearer $token';
        print(
            '💰 Using authenticated Railway API call (Battery: $_batteryLevel%)');
      } else {
        print('💡 Using public Railway API call (Battery: $_batteryLevel%)');
      }

      // Shorter timeout in power saving mode
      final timeout =
          _powerSavingMode ? Duration(seconds: 5) : Duration(seconds: 10);

      final response = await http
          .get(
            Uri.parse(
                'https://crafted-well-laravel.up.railway.app/api/products'),
            headers: headers,
          )
          .timeout(timeout);

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
                      'Skin type specific',
                      if (_currentClimate != 'unknown')
                        'Optimized for $_currentClimate climate'
                    ],
                  ))
              .toList();

          await _cacheProducts(_railwayProducts);
          print(
              '✅ Railway API loaded: ${_railwayProducts.length} products (Climate: $_currentClimate)');
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

  // External Makeup API data
  Future<void> loadExternalMakeupData() async {
    if (!_isOnline) {
      print('📴 Offline - skipping external makeup API');
      return;
    }

    // Skip in extreme power saving mode
    if (_batteryLevel <= 10) {
      print('🔋 Power saving - skipping external makeup API');
      return;
    }

    try {
      final response = await http
          .get(Uri.parse(
              'http://makeup-api.herokuapp.com/api/v1/products.json?product_type=foundation&brand=maybelline'))
          .timeout(Duration(seconds: _powerSavingMode ? 5 : 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

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

  // Custom Products API integration
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
      print('💰 Creating new custom product via API');

      final getResponse = await http.get(
        Uri.parse(
            'https://crafted-well-laravel.up.railway.app/api/custom-products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (getResponse.statusCode == 200) {
        final getData = json.decode(getResponse.body);

        if (getData['status'] == 'success' &&
            getData['data'] != null &&
            getData['data'].isNotEmpty) {
          final List<dynamic> existingProducts = getData['data'];

          _customProducts = existingProducts
              .map((json) => Product(
                    id: 'custom_${json['id'] ?? json['custom_product_id']}',
                    name: json['name'] ??
                        json['product_name'] ??
                        'Custom Product',
                    description: json['description'] ??
                        'Custom formulated product based on your survey',
                    ingredients: json['ingredients'] is List
                        ? (json['ingredients'] as List).join(', ')
                        : json['ingredients']?.toString() ??
                            'Custom formulated ingredients',
                    usage:
                        json['usage'] ?? 'Apply as directed for your skin type',
                    price: double.tryParse(json['price']?.toString() ??
                            json['total_price']?.toString() ??
                            '0') ??
                        79.99,
                    imageAsset: 'assets/images/product-image-2.png',
                    benefits: [
                      'Custom formulated for you',
                      'Based on your survey responses',
                      'Personalized skincare solution',
                      if (_currentClimate != 'unknown')
                        'Adapted for $_currentClimate climate'
                    ],
                  ))
              .toList();

          print(
              '✅ Existing custom products loaded: ${_customProducts.length} products');
        } else {
          await _createNewCustomProduct(token);
        }
      } else {
        await _createNewCustomProduct(token);
      }
    } catch (e) {
      print('❌ Custom products API error: $e');
      await _createDemoCustomProducts();
    }
    notifyListeners();
  }

  // Create a new custom product with actual survey data
  Future<void> _createNewCustomProduct(String token) async {
    try {
      print('🎨 Creating new custom product with survey data');

      final surveyData = {
        'base_product_id': 1,
        'profile_data': {
          'skin_type': 'combination',
          'skin_concerns': ['hydration', 'anti-aging'],
          'environmental_factors':
              _currentClimate != 'unknown' ? _currentClimate : 'urban',
          'allergies': ['fragrances']
        },
        'product_name': 'Your Personalized Skincare Formula',
        'custom_notes':
            'Formulated based on your survey responses for combination skin in $_currentClimate environment'
      };

      final response = await http
          .post(
            Uri.parse(
                'https://crafted-well-laravel.up.railway.app/api/custom-products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(surveyData),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success' && data['data'] != null) {
          final productData = data['data'];
          final customProduct = Product(
            id: 'custom_${productData['id'] ?? productData['custom_product_id']}',
            name: productData['name'] ??
                productData['product_name'] ??
                'Your Personalized Formula',
            description: productData['description'] ??
                'Custom formulated based on your survey responses',
            ingredients: productData['ingredients'] is List
                ? (productData['ingredients'] as List).join(', ')
                : productData['ingredients']?.toString() ??
                    'Hyaluronic Acid, Niacinamide, Ceramides',
            usage:
                productData['usage'] ?? 'Apply 2-3 drops morning and evening',
            price: double.tryParse(productData['price']?.toString() ??
                    productData['total_price']?.toString() ??
                    '0') ??
                89.99,
            imageAsset: 'assets/images/product-image-2.png',
            benefits: [
              'Custom formulated for your skin type',
              'Based on your survey answers',
              'Targets your specific concerns',
              'Professional-grade ingredients',
              if (_currentClimate != 'unknown')
                'Optimized for $_currentClimate climate'
            ],
          );

          _customProducts = [customProduct];
          print('✅ Custom product added to app');
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        print('⚠️ Custom product creation failed: ${response.statusCode}');
        await _createDemoCustomProducts();
      }
    } catch (e) {
      print('❌ Custom product creation error: $e');
      await _createDemoCustomProducts();
    }
  }

  // Create demo custom products
  Future<void> _createDemoCustomProducts() async {
    _customProducts = [
      Product(
        id: 'custom_demo_1',
        name: 'Your Personalized Hydra-Glow Serum',
        description:
            'Custom serum formulated based on your survey: combination skin with hydration concerns${_currentClimate != 'unknown' ? ' for $_currentClimate climate' : ''}',
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
          'Clinically tested ingredients',
          if (_currentClimate != 'unknown')
            'Adapted for $_currentClimate climate'
        ],
      ),
    ];

    print('✅ Demo custom products created: ${_customProducts.length} products');
  }

  // Load offline JSON data
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

  // Cache products to database
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

  // Load cached products from database
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

  // Save survey data
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

  // Refresh all data
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

  // NEW: Get battery status message for UI
  String getBatteryStatusMessage() {
    if (_batteryLevel <= 5) {
      return '🔋 Critical battery - Limited functionality';
    } else if (_batteryLevel <= 15) {
      return '🔋 Low battery - Power saving mode active';
    } else if (_batteryLevel <= 30) {
      return '🔋 Moderate battery - Reduced API frequency';
    } else {
      return '🔋 Good battery - Full functionality';
    }
  }

  // NEW: Get climate recommendation message
  String getClimateRecommendation() {
    switch (_currentClimate) {
      case 'tropical':
        return '🌴 Tropical climate detected - Showing lightweight, oil-free products';
      case 'dry':
        return '🏜️ Dry climate detected - Showing moisturizing, barrier-repair products';
      case 'urban':
        return '🏢 Urban environment detected - Showing anti-pollution products';
      case 'moderate':
        return '🌤️ Moderate climate detected - Showing balanced skincare products';
      default:
        return '📍 Enable location for climate-optimized recommendations';
    }
  }

  // ENHANCED: Device status summary with meaningful info
  String getDeviceStatusSummary() {
    final List<String> status = [];

    if (_batteryLevel > 0) {
      final batteryIcon = _batteryLevel <= 15
          ? '🔴'
          : _batteryLevel <= 30
              ? '🟡'
              : '🟢';
      status.add('$batteryIcon $_batteryLevel%');
    }

    status.add(_isOnline ? '🌐 Online' : '📴 Offline');

    if (_location != null) {
      final climateIcon = _getClimateIcon(_currentClimate);
      status.add('$climateIcon $_currentClimate');
    }

    if (_powerSavingMode) {
      status.add('⚡ Power Save');
    }

    return status.join(' • ');
  }

  String _getClimateIcon(String climate) {
    switch (climate) {
      case 'tropical':
        return '🌴';
      case 'dry':
        return '🏜️';
      case 'urban':
        return '🏢';
      case 'moderate':
        return '🌤️';
      default:
        return '📍';
    }
  }

  // NEW: Get data source context message for UI
  String getDataSourceMessage() {
    if (!_isOnline) {
      return '📴 Offline Mode: Showing cached products';
    } else if (_isUserLoggedIn) {
      return '🌐 Online: Personalized recommendations${_currentClimate != 'unknown' ? ' for $_currentClimate climate' : ''}';
    } else {
      return '🌐 Online: General products (login for personalized)';
    }
  }

  // NEW: Force battery level for testing
  void setBatteryLevelForTesting(int level) {
    _batteryLevel = level;
    _updatePowerSavingMode();
    _adjustApiFrequency();
    notifyListeners();
    print('🧪 Test: Battery set to $_batteryLevel%');
  }

  // NEW: Force location for testing
  void setLocationForTesting(double lat, double lng) {
    _location = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
    _currentClimate = _determineClimate(_location!);
    notifyListeners();
    print('🧪 Test: Location set to $lat, $lng ($_currentClimate climate)');
  }
}
