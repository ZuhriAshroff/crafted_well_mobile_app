class Product {
  final String id;
  final String name;
  final String description;
  final String ingredients;
  final String usage;
  final double price;
  final String imageAsset;
  final List<String> benefits;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.usage,
    required this.price,
    required this.imageAsset,
    required this.benefits,
  });

  static List<Product> sampleProducts = [
    Product(
      id: '1',
      name: 'Hydrating Face Serum',
      description:
          'A lightweight serum that deeply hydrates and plumps the skin, reducing fine lines and improving texture.',
      ingredients: 'Hyaluronic Acid, Niacinamide, Peptides, Vitamin E',
      usage:
          'Apply 2-3 drops to clean, damp skin morning and evening. Follow with moisturizer.',
      price: 45.99,
      imageAsset: 'assets/images/product-image-1.png',
      benefits: [
        'Deep hydration',
        'Reduces fine lines',
        'Improves skin texture',
        'Plumps skin'
      ],
    ),
  ];
}
