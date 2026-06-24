import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String shopId;
  final String shopName;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.shopId,
    required this.shopName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
  // shop can be either a string ID or a populated object
  String shopId = '';
  String shopName = '';
  
  if (map['shop'] is Map) {
    shopId = map['shop']['_id'] ?? '';
    shopName = map['shop']['name'] ?? '';
  } else if (map['shop'] is String) {
    shopId = map['shop'];
  } else {
    shopId = map['shopId'] ?? '';
    shopName = map['shopName'] ?? '';
  }

  return ProductModel(
    id: map['_id'] ?? map['id'] ?? '',
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    price: (map['price'] ?? 0).toDouble(),
    imageUrl: map['imageUrl'] ?? '',
    category: map['category'] ?? '',
    shopId: shopId,
    shopName: shopName,
    rating: (map['rating'] ?? 0).toDouble(),
    reviewCount: map['reviewCount'] ?? 0,
    isAvailable: map['isAvailable'] ?? true,
  );
}

  @override
  List<Object?> get props => [
        id, name, description, price,
        imageUrl, category, shopId, shopName,
        rating, reviewCount, isAvailable,
      ];
}