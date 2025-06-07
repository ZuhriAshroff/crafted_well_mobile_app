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

class AppProvider extends ChangeNotifier {
  // Your existing static products
  List<Product> _localProducts = Product.sampleProducts;

  // New: Railway API products
  List<Product> _railwayProducts = [];

  // New: Offline JSON products (assignment requirement)
  List<Product> _offlineProducts = [];

  // New: External JSON data (assignment requirement)
  List<Map<String, dynamic>> _externalJsonData = [];

  // Device capabilities
  bool _isOnline = true;
  Position? _location;
  int _batteryLevel = 0;
  bool _isLoading = false;

  // Database
  Database? _database;

  // Getters
  List<Product> get allProducts =>
      [..._localProducts, ..._railwayProducts, ..._offlineProducts];
  List<Product> get localProducts => _localProducts;
  List<Product> get railwayProducts => _railwayProducts;
  List<Product> get offlineProducts => _offlineProducts;
  List<Map<String, dynamic>> get externalJsonData => _externalJsonData;
  bool get isOnline => _isOnline;
  Position? get location => _location;
  int get batteryLevel => _batteryLevel;
  bool get isLoading => _isLoading;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize in proper order
      await _initDatabase();
      await _monitorConnectivity();
      await _loadDeviceCapabilities();

      // Load data
      await loadRailwayData();
      await loadExternalJsonData();
      await loadLocalJsonData();

      print('✓ App initialization complete');
    } catch (e) {
      print('App initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Monitor connectivity (assignment requirement)
  Future<void> _monitorConnectivity() async {
    try {
      // Check initial connectivity
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      // Listen for changes
      connectivity.onConnectivityChanged.listen((result) {
        _isOnline = result != ConnectivityResult.none;
        notifyListeners();
      });

      print('✓ Connectivity monitoring initialized: $_isOnline');
    } catch (e) {
      print('Connectivity error: $e');
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
          print('✓ GPS location acquired');
        }
      }

      // Battery Level
      final battery = Battery();
      _batteryLevel = await battery.batteryLevel;

      // Listen for battery changes
      battery.onBatteryStateChanged.listen((state) async {
        _batteryLevel = await battery.batteryLevel;
        notifyListeners();
      });

      print('✓ Battery monitoring initialized: $_batteryLevel%');
      notifyListeners();
    } catch (e) {
      print('Device capabilities error: $e');
    }
  }

  // SQLite Database (assignment requirement) - FIXED
  Future<void> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'crafted_well.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create products cache table
          await db.execute(
            'CREATE TABLE cached_products(id TEXT PRIMARY KEY, name TEXT, description TEXT, price REAL, created_at TEXT)',
          );

          // Create survey responses table
          await db.execute(
            'CREATE TABLE survey_responses(id INTEGER PRIMARY KEY AUTOINCREMENT, skin_type TEXT, concerns TEXT, environment TEXT, created_at TEXT)',
          );

          print('✓ Database tables created');
        },
      );

      print('✓ SQLite database initialized');
    } catch (e) {
      print('Database initialization error: $e');
    }
  }

  // Railway API integration (assignment requirement)
  Future<void> loadRailwayData() async {
    if (!_isOnline) {
      print('Offline - loading cached Railway products');
      _railwayProducts = await _loadCachedProducts();
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://crafted-well-laravel.up.railway.app/api/products'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));

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

          // Cache in SQLite
          await _cacheProducts(_railwayProducts);
          print('✓ Railway API loaded: ${_railwayProducts.length} products');
        }
      }
    } catch (e) {
      print('Railway API error: $e');
      // Load from cache if API fails
      _railwayProducts = await _loadCachedProducts();
    }
    notifyListeners();
  }

  // External JSON data (assignment requirement)
  Future<void> loadExternalJsonData() async {
    if (!_isOnline) return;

    try {
      final response = await http
          .get(
            Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _externalJsonData = data
            .map((item) => {
                  'id': item['id'],
                  'title': item['title'],
                  'body': item['body'],
                })
            .toList();

        print('✓ External JSON loaded: ${_externalJsonData.length} items');
        notifyListeners();
      }
    } catch (e) {
      print('External JSON error: $e');
    }
  }

  // Load local JSON data (assignment requirement)
  Future<void> loadLocalJsonData() async {
    try {
      // Load local JSON file from assets
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

      print('✓ Local JSON loaded: ${_offlineProducts.length} products');
      notifyListeners();
    } catch (e) {
      print('Local JSON loading error: $e');
      // If local JSON fails, create fallback offline products
      _offlineProducts = [
        Product(
          id: 'offline_fallback',
          name: 'Offline Emergency Product',
          description: 'Fallback product when JSON loading fails',
          ingredients: 'Basic ingredients',
          usage: 'Use as needed',
          price: 0.0,
          imageAsset: 'assets/images/product-image-1.png',
          benefits: ['Always available offline'],
        ),
      ];
      notifyListeners();
    }
  }

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
      print('✓ Products cached to SQLite');
    } catch (e) {
      print('Cache products error: $e');
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

      print('✓ Loaded ${cachedProducts.length} cached products');
      return cachedProducts;
    } catch (e) {
      print('Load cached products error: $e');
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

      print('✓ Survey data saved: $skinType, $concerns, $environment');
    } catch (e) {
      print('Save survey data error: $e');
    }
  }

  // Get survey responses (bonus functionality)
  Future<List<Map<String, dynamic>>> getSurveyResponses() async {
    if (_database == null) return [];

    try {
      return await _database!
          .query('survey_responses', orderBy: 'created_at DESC');
    } catch (e) {
      print('Get survey responses error: $e');
      return [];
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadRailwayData(),
      loadExternalJsonData(),
      loadLocalJsonData(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
