import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/railway/railway_product.dart';

class DataService {
  static Database? _database;
  static const String railwayUrl =
      'https://crafted-well-laravel.up.railway.app/api/products';
  static const String externalJsonUrl =
      'https://jsonplaceholder.typicode.com/posts';

  // Initialize SQLite database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'crafted_well.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, category TEXT, price REAL, imageUrl TEXT, description TEXT)',
        );
      },
    );
    return _database!;
  }

  // Check connectivity
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Fetch from Railway API
  Future<List<RailwayProduct>> fetchRailwayProducts() async {
    final response = await http.get(Uri.parse(railwayUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productsJson = data['data'];
      return productsJson.map((json) => RailwayProduct.fromJson(json)).toList();
    }
    throw Exception('Failed to load Railway products');
  }

  // Fetch external JSON (assignment requirement)
  Future<List<Map<String, dynamic>>> fetchExternalJson() async {
    final response = await http.get(Uri.parse(externalJsonUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .take(10)
          .map((item) => {
                'id': item['id'],
                'title': item['title'],
                'body': item['body'],
              })
          .toList();
    }
    throw Exception('Failed to load external JSON');
  }

  // Cache products locally (SQLite write)
  Future<void> cacheProducts(List<RailwayProduct> products) async {
    final db = await database;
    for (var product in products) {
      await db.insert('products', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Get cached products (SQLite read)
  Future<List<RailwayProduct>> getCachedProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps
        .map((map) => RailwayProduct(
              id: map['id'],
              name: map['name'],
              category: map['category'],
              price: map['price'],
              imageUrl: map['imageUrl'],
              description: map['description'],
            ))
        .toList();
  }

  // Main method - handles online/offline
  Future<List<RailwayProduct>> getProducts() async {
    if (await isOnline()) {
      try {
        final products = await fetchRailwayProducts();
        await cacheProducts(products); // Cache for offline use
        return products;
      } catch (e) {
        return await getCachedProducts(); // Fallback to cache
      }
    } else {
      return await getCachedProducts(); // Offline mode
    }
  }
}
