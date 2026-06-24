import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/order_repository.dart';
import '../../../../core/network/api_service.dart';
import '../../../../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(),
);

final myOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final api = ApiService();
  final token = await api.getToken();
  if (token == null || token.isEmpty) return [];
  final repo = ref.read(orderRepositoryProvider);
  return repo.getMyOrders();
});

final orderDetailProvider = FutureProvider.autoDispose
    .family<OrderModel, String>((ref, orderId) async {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getOrderById(orderId);
});