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
        // MODIFIED LOGIC: Always allow access to offline products
        // Only show personalized products when online and survey completed
        final bool showPersonalizedProducts = provider.isOnline &&
            NavigationState.hasCompletedSurvey &&
            UserManager.isLoggedIn;

        return Scaffold(
          appBar: AppBar(
            title: Text(showPersonalizedProducts
                ? 'Your Recommended Products'
                : 'Demo Products'),
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
                    color:
                        showPersonalizedProducts ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showPersonalizedProducts
                          ? Icons.person
                          : Icons.visibility,
                      size: 16,
                      color: showPersonalizedProducts
                          ? Colors.green
                          : Colors.orange,
                    ),
                    SizedBox(width: 6),
                    Text(
                      showPersonalizedProducts ? 'Personalized' : 'Demo Mode',
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
              // Show upgrade message when not showing personalized products
              if (!showPersonalizedProducts) ...[
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Viewing Demo Products',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        provider.isOnline
                            ? 'Complete the survey to get personalized product recommendations based on your skin type and environment.'
                            : 'Connect to internet and complete the survey to get personalized product recommendations.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      if (!provider.isOnline ||
                          !NavigationState.hasCompletedSurvey) ...[
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (!provider.isOnline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Please connect to internet first'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              // Navigate back to home/survey start - adjust route as needed
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/', // or whatever your home/survey route is
                                (route) => false,
                              );
                            }
                          },
                          icon: Icon(Icons.quiz, size: 16),
                          label: Text(
                            !provider.isOnline
                                ? 'Connect & Take Survey'
                                : 'Take Survey',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Enhanced status bar with battery and climate impact
              Container(
                padding: EdgeInsets.all(16),
                color: showPersonalizedProducts
                    ? Theme.of(context).primaryColor.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                child: Column(
                  children: [
                    // Battery impact indicator
                    if (provider.batteryLevel <= 20) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.battery_alert,
                                color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.getBatteryStatusMessage(),
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Climate recommendation
                    if (provider.location != null) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.getClimateRecommendation(),
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Data source info
                    Row(
                      children: [
                        Icon(
                            showPersonalizedProducts
                                ? Icons.analytics
                                : Icons.storage,
                            size: 16,
                            color: showPersonalizedProducts
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            showPersonalizedProducts
                                ? provider.getDataSourceMessage()
                                : 'Showing Demo/Offline Products - No Survey Required',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: showPersonalizedProducts
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[700],
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (showPersonalizedProducts) ...[
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
                    ] else ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDataSourceChip('Demo Products',
                              provider.allProducts.length, Colors.grey),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // External Makeup API horizontal scroll (only when showing personalized products)
              if (showPersonalizedProducts &&
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

              // Main product list
              Expanded(
                child: provider.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading products...'),
                            SizedBox(height: 8),
                            Text(
                              showPersonalizedProducts
                                  ? 'Fetching personalized recommendations...'
                                  : 'Loading demo products...',
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
                                  'No products found to display',
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
                              itemCount: _getSortedProducts(provider).length,
                              itemBuilder: (context, index) {
                                final product =
                                    _getSortedProducts(provider)[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ProductCard(
                                    product: product,
                                    index: index,
                                    dataSource: _getProductDataSource(
                                        product, provider),
                                    isDemo: !showPersonalizedProducts,
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

  // Sort products to show custom products first
  List<Product> _getSortedProducts(AppProvider provider) {
    final List<Product> sortedProducts = List.from(provider.allProducts);

    // Sort by data source priority: Custom > SSP API > Local/Demo
    sortedProducts.sort((a, b) {
      int getPriority(Product product) {
        if (provider.customProducts.any((p) => p.id == product.id))
          return 1; // Custom first
        if (provider.railwayProducts.any((p) => p.id == product.id))
          return 2; // SSP API second
        return 3; // Local/Demo/Others last
      }

      return getPriority(a).compareTo(getPriority(b));
    });

    return sortedProducts;
  }

  // Determine which data source this product came from
  String _getProductDataSource(Product product, AppProvider provider) {
    if (provider.railwayProducts.any((p) => p.id == product.id)) {
      return 'SSP API';
    } else if (provider.customProducts.any((p) => p.id == product.id)) {
      return 'Custom';
    } else if (provider.offlineProducts.any((p) => p.id == product.id)) {
      return 'Demo Product';
    } else if (provider.localProducts.any((p) => p.id == product.id)) {
      return 'Demo Product';
    }
    return 'Demo Product';
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
  final bool isDemo;

  const ProductCard({
    Key? key,
    required this.product,
    required this.index,
    required this.dataSource,
    this.isDemo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get color for data source badge
    Color getSourceColor() {
      if (isDemo) return Colors.grey;

      switch (dataSource) {
        case 'SSP API':
          return Colors.blue;
        case 'Custom':
          return Colors.red;
        case 'Demo Product':
          return Colors.grey;
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
                // Data source badge
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
                      isDemo ? 'DEMO' : dataSource,
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
                          '\${_formatPrice(product.price)}',
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
