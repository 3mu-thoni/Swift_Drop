import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}