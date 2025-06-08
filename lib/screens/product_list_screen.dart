// lib/screens/product_list_screen.dart
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
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // NEW LOGIC: Allow offline access without survey requirement
        final bool requiresSurveyAndLogin = provider.isOnline;

        // Check if user came from survey and is logged in (only when online)
        if (requiresSurveyAndLogin &&
            (!NavigationState.hasCompletedSurvey || !UserManager.isLoggedIn)) {
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

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.isOfflineMode
                ? 'Demo Products (Offline)'
                : 'Your Recommended Products'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Enhanced device status indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isOnline ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: provider.isOnline ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 6),
                    Text(
                      provider.getDeviceStatusSummary(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Data source context message
              Container(
                padding: EdgeInsets.all(16),
                color: provider.isOfflineMode
                    ? Colors.orange.withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.05),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                            provider.isOfflineMode
                                ? Icons.cloud_off
                                : Icons.analytics,
                            size: 16,
                            color: provider.isOfflineMode
                                ? Colors.orange
                                : Theme.of(context).primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.isOfflineMode
                                ? 'Offline Mode: Demo Products Available'
                                : provider.getDataSourceMessage(),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: provider.isOfflineMode
                                      ? Colors.orange
                                      : Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (!provider.isOfflineMode) ...[
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDataSourceChip('SSP API',
                              provider.railwayProducts.length, Colors.blue),
                          _buildDataSourceChip('Local',
                              provider.localProducts.length, Colors.green),
                          _buildDataSourceChip('Custom',
                              provider.customProducts.length, Colors.red),
                          _buildDataSourceChip(
                              'Makeup API',
                              provider.externalMakeupData.length,
                              Colors.purple),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // External Makeup API horizontal scroll (online only)
              if (provider.isOnline &&
                  provider.externalMakeupData.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.palette, size: 16, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'External Beauty Products (Makeup API)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.externalMakeupData.length,
                    itemBuilder: (context, index) {
                      final item = provider.externalMakeupData[index];
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.purple.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['brand']} ${item['product_type']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                item['name'] ?? 'No name',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.purple.shade600),
                              ),
                            ),
                            Text(
                              '\$${item['price'] ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.purple.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                Divider(color: Theme.of(context).dividerColor.withOpacity(0.3)),
              ],

              // Offline mode message
              if (provider.isOfflineMode) ...[
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange.shade700),
                          SizedBox(width: 8),
                          Text(
                            'Browsing Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You\'re viewing demo products while offline. Connect to internet for personalized recommendations based on your survey.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Main product list
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading your products...'),
                            SizedBox(height: 8),
                            Text(
                              provider.isOnline
                                  ? 'Fetching from API...'
                                  : 'Loading offline data...',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
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
                                Text(
                                  provider.isOnline
                                      ? 'Check your API connection'
                                      : 'No offline products cached',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    await provider.refreshData();
                                    await provider.updateAuthState();
                                  },
                                  child: Text('Retry Loading'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await provider.refreshData();
                              await provider.updateAuthState();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.allProducts.length,
                              itemBuilder: (context, index) {
                                final product = provider.allProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ProductCard(
                                    product: product,
                                    index: index,
                                    dataSource: _getProductDataSource(
                                        product, provider),
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

  // Determine which data source this product came from
  String _getProductDataSource(Product product, AppProvider provider) {
    if (provider.railwayProducts.any((p) => p.id == product.id)) {
      return 'SSP API';
    } else if (provider.customProducts.any((p) => p.id == product.id)) {
      return 'Custom';
    } else if (provider.offlineProducts.any((p) => p.id == product.id)) {
      return 'Offline JSON';
    } else if (provider.localProducts.any((p) => p.id == product.id)) {
      return 'Static Data';
    }
    return 'Unknown';
  }

  Widget _buildDataSourceChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;
  final String dataSource;

  const ProductCard({
    Key? key,
    required this.product,
    required this.index,
    required this.dataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get color for data source badge
    Color getSourceColor() {
      switch (dataSource) {
        case 'SSP API':
          return Colors.blue;
        case 'Custom':
          return Colors.red;
        case 'Offline JSON':
          return Colors.orange;
        case 'Static Data':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

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
            // Product Image with data source badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Hero(
                    tag: 'product_${product.id}_$index',
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
                // Data source badge (for assignment demonstration)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getSourceColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dataSource,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '\${product.price.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text('View', style: TextStyle(fontSize: 12)),
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
