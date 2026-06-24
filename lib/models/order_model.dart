import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });

  double get totalPrice => price * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['product'] ?? map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'product': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  @override
  List<Object?> get props => [productId, name, price, quantity];
}

class OrderModel extends Equatable {
  final String id;
  final String shopId;
  final String shopName;
  final List<OrderItemModel> items;
  final String status;
  final String deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final String? riderId;
  final String? riderName;

  const OrderModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.items,
    required this.status,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.riderId,
    this.riderName,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final shop = map['shop'];
    return OrderModel(
      id: map['_id'] ?? map['id'] ?? '',
      shopId: shop is Map ? shop['_id'] ?? '' : map['shop'] ?? '',
      shopName: shop is Map ? shop['name'] ?? '' : '',
      items: (map['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromMap(e))
          .toList(),
      status: map['status'] ?? 'pending',
      deliveryAddress: map['deliveryAddress'] ?? '',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      riderId: map['rider'] is Map ? map['rider']['_id'] : null,
      riderName: map['rider'] is Map ? map['rider']['name'] : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'on_the_way': return 'On the way';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  @override
  List<Object?> get props => [id, status, total, createdAt];
}