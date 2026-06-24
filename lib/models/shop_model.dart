import 'package:equatable/equatable.dart';

class ShopModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final bool isOpen;
  final String address;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.deliveryTime = '30-45 min',
    this.deliveryFee = 0.0,
    this.isOpen = true,
    this.address = '',
  });

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      deliveryTime: map['deliveryTime'] ?? '30-45 min',
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      isOpen: map['isOpen'] ?? true,
      address: map['address'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, imageUrl,
        category, rating, reviewCount,
        deliveryTime, deliveryFee, isOpen, address,
      ];
}