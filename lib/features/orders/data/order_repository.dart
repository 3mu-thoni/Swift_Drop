import '../../../core/network/api_service.dart';
import '../../../models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderRepository {
  final _api = ApiService();

  Future<OrderModel> createOrder({
  required String shopId,
  required List<Map<String, dynamic>> items,
  required String deliveryAddress,
  required double deliveryFee,
  required String paymentMethod,
  String? notes,
}) async {
  try {
    final response = await _api.post('/orders', data: {
      'shopId': shopId,
      'items': items,
      'deliveryAddress': deliveryAddress,
      'deliveryFee': deliveryFee,
      'paymentMethod': paymentMethod,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return OrderModel.fromMap(response.data);
  } catch (e) {
    debugPrint('❌ Create order error: $e');
    rethrow;
  }
}

  Future<List<OrderModel>> getMyOrders() async {
    final response = await _api.get('/orders/my');
    final List data = response.data;
    return data.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _api.get('/orders/$id');
    return OrderModel.fromMap(response.data);
  }
}