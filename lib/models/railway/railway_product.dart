class RailwayProduct {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;

  RailwayProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory RailwayProduct.fromJson(Map<String, dynamic> json) {
    return RailwayProduct(
      id: json['product_id'],
      name: json['product_name'],
      category: json['base_category'],
      price: double.parse(json['standard_price'].toString()),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
