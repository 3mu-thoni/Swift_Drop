import '../../../core/network/api_service.dart';
import '../../../models/shop_model.dart';
import '../../../models/product_model.dart';

class ShopRepository {
  final _api = ApiService();

  Future<List<ShopModel>> getShops({
    String? category,
    String? search,
  }) async {
    final response = await _api.get('/shops', params: {
      if (category != null && category != 'All') 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    });

    final List data = response.data['shops'];
    return data.map((e) => ShopModel.fromMap(e)).toList();
  }

  Future<ShopModel> getShopById(String id) async {
    final response = await _api.get('/shops/$id');
    return ShopModel.fromMap(response.data);
  }

  Future<List<ProductModel>> getShopProducts(String shopId) async {
    final response = await _api.get('/shops/$shopId/products');
    final List data = response.data;
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
  }) async {
    final response = await _api.get('/products', params: {
      if (category != null) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    });

    final List data = response.data;
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }
}