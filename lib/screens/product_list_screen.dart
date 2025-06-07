import 'package:crafted_well_mobile_app/providers/app_provider.dart';
import 'package:crafted_well_mobile_app/screens/product_details_screen.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:crafted_well_mobile_app/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/navigation_state.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if user came from survey and is logged in
    if (!NavigationState.hasCompletedSurvey || !UserManager.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete the survey first to view your personalized products',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      );
    }

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Recommended Products'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Show connectivity status
              Icon(
                provider.isOnline ? Icons.wifi : Icons.wifi_off,
                color: provider.isOnline ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text('${provider.batteryLevel}%', style: TextStyle(fontSize: 12)),
              SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              // Device capabilities banner (assignment requirement)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCapabilityChip(
                      'Battery: ${provider.batteryLevel}%',
                      Icons.battery_std,
                      provider.batteryLevel > 20 ? Colors.green : Colors.red,
                    ),
                    _buildCapabilityChip(
                      provider.isOnline ? 'Online' : 'Offline',
                      provider.isOnline ? Icons.wifi : Icons.wifi_off,
                      provider.isOnline ? Colors.green : Colors.red,
                    ),
                    if (provider.location != null)
                      _buildCapabilityChip(
                        'GPS Active',
                        Icons.location_on,
                        Colors.blue,
                      ),
                  ],
                ),
              ),

              // Data source counts
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDataSourceChip(
                        'API', provider.railwayProducts.length, Colors.blue),
                    _buildDataSourceChip(
                        'Local', provider.localProducts.length, Colors.green),
                    _buildDataSourceChip('Offline',
                        provider.offlineProducts.length, Colors.orange),
                    _buildDataSourceChip('External',
                        provider.externalJsonData.length, Colors.purple),
                  ],
                ),
              ),

              // External JSON section (assignment requirement) - FIXED LAYOUT
              if (provider.externalJsonData.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'External JSON Data (JSONPlaceholder)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 90, // FIXED HEIGHT
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.externalJsonData.length,
                    itemBuilder: (context, index) {
                      final item = provider.externalJsonData[index];
                      return Container(
                        width: 220, // FIXED WIDTH
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // PREVENT OVERFLOW
                          children: [
                            Text(
                              'External Post #${item['id']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                item['title'] ?? 'No title',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Divider(),
              ],

              // Product list
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading your personalized products...'),
                          ],
                        ),
                      )
                    : provider.allProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No products available',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: provider.refreshData,
                                  child: Text('Retry Loading'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: provider.refreshData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.allProducts.length,
                              itemBuilder: (context, index) {
                                final product = provider.allProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ProductCard(
                                    product: product,
                                    index:
                                        index, // PASS INDEX FOR UNIQUE HERO TAGS
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }

  Widget _buildCapabilityChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const ProductCard({
    Key? key,
    required this.product,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Hero(
                tag: 'product_${product.id}_$index', // UNIQUE HERO TAG
                child: Image.asset(
                  product.imageAsset,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
