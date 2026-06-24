import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../models/order_model.dart';

class RiderRepository {
  final _api = ApiService();

  Future<List<OrderModel>> getAvailableOrders() async {
    final response = await _api.get('/rider/orders');
    final List data = response.data;
    return data.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderModel>> getMyDeliveries() async {
    final response = await _api.get('/rider/my-orders');
    final List data = response.data;
    return data.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<void> acceptOrder(String orderId) async {
    await _api.patch('/rider/orders/$orderId/accept');
  }

  Future<void> markDelivered(String orderId) async {
    await _api.patch('/orders/$orderId/status',
        data: {'status': 'delivered', 'note': 'Delivered by rider'});
  }
}

final riderRepositoryProvider = Provider<RiderRepository>(
  (ref) => RiderRepository(),
);

final availableOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return ref.read(riderRepositoryProvider).getAvailableOrders();
});

final myDeliveriesProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  return ref.read(riderRepositoryProvider).getMyDeliveries();
});