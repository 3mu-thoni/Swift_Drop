import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(ProductModel product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItemModel(product: product, quantity: 1)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clearCart() => state = [];

  double get totalAmount =>
      state.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});