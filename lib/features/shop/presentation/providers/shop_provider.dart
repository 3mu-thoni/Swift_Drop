import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/shop_repository.dart';
import '../../../../models/shop_model.dart';
import '../../../../models/product_model.dart';

final shopRepositoryProvider = Provider<ShopRepository>(
  (ref) => ShopRepository(),
);

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final searchQueryProvider = StateProvider<String>((ref) => '');

final shopsProvider = FutureProvider.autoDispose<List<ShopModel>>((ref) async {
  final repo = ref.read(shopRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);
  return repo.getShops(category: category, search: search);
});

final shopProductsProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, String>((ref, shopId) async {
  final repo = ref.read(shopRepositoryProvider);
  return repo.getShopProducts(shopId);
});

final featuredProductsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.read(shopRepositoryProvider);
  return repo.getProducts();
});