import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/network/api_service.dart';
import '../../../../models/order_model.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _socketService = SocketService();
  OrderModel? _order;
  bool _isLoading = true;
  String _currentStatus = 'pending';
  double? _riderLat;
  double? _riderLng;

  final List<Map<String, dynamic>> _statusSteps = [
    {
      'status': 'pending',
      'label': 'Order Placed',
      'icon': Icons.receipt_long,
      'description': 'Your order has been received',
    },
    {
      'status': 'confirmed',
      'label': 'Confirmed',
      'icon': Icons.check_circle_outline,
      'description': 'Restaurant confirmed your order',
    },
    {
      'status': 'preparing',
      'label': 'Preparing',
      'icon': Icons.restaurant,
      'description': 'Your food is being prepared',
    },
    {
      'status': 'on_the_way',
      'label': 'On the way',
      'icon': Icons.delivery_dining,
      'description': 'Rider is heading to you',
    },
    {
      'status': 'delivered',
      'label': 'Delivered',
      'icon': Icons.home,
      'description': 'Enjoy your order!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _connectSocket();
  }

  Future<void> _loadOrder() async {
    try {
      final api = ApiService();
      final response = await api.get('/orders/${widget.orderId}');
      setState(() {
        _order = OrderModel.fromMap(response.data);
        _currentStatus = _order!.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _connectSocket() {
    _socketService.connect();
    _socketService.trackOrder(widget.orderId);

    _socketService.onStatusUpdate((data) {
      if (data['orderId'] == widget.orderId) {
        setState(() {
          _currentStatus = data['status'];
        });
      }
    });

    _socketService.onLocationUpdate((data) {
      setState(() {
        _riderLat = data['lat']?.toDouble();
        _riderLng = data['lng']?.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _socketService.off('status:update');
    _socketService.off('location:update');
    super.dispose();
  }

  int get _currentStepIndex {
    return _statusSteps.indexWhere(
      (s) => s['status'] == _currentStatus,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF3B82F6);
      case 'preparing': return const Color(0xFF8B5CF6);
      case 'on_the_way': return const Color(0xFF2EC4B6);
      case 'delivered': return const Color(0xFF22C55E);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFFF6B35)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFEEEFF2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${widget.orderId.substring(widget.orderId.length > 8 ? widget.orderId.length - 8 : 0).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              if (_order != null)
                                Text(
                                  '${_order!.items.length} items • KSh ${_order!.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor(_currentStatus)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentStatus
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(_currentStatus),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Map placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFEEEFF2)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Live map tracking',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                              if (_riderLat != null)
                                Text(
                                  'Rider at: ${_riderLat!.toStringAsFixed(4)}, ${_riderLng!.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    color: Color(0xFF22C55E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_currentStatus == 'on_the_way')
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 8,
                                      color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status timeline
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFEEEFF2)),
                    ),
                    child: Column(
                      children: List.generate(
                        _statusSteps.length,
                        (index) {
                          final step = _statusSteps[index];
                          final isCompleted =
                              index <= _currentStepIndex;
                          final isCurrent =
                              index == _currentStepIndex;
                          final isLast =
                              index == _statusSteps.length - 1;

                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Timeline indicator
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 300),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFFF3F4F6),
                                      shape: BoxShape.circle,
                                      border: isCurrent
                                          ? Border.all(
                                              color: const Color(
                                                  0xFFFF6B35),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      step['icon'] as IconData,
                                      size: 18,
                                      color: isCompleted
                                          ? Colors.white
                                          : const Color(0xFFB0B7C3),
                                    ),
                                  ),
                                  if (!isLast)
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 300),
                                      width: 2,
                                      height: 40,
                                      color: index < _currentStepIndex
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Step content
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isLast ? 0 : 24,
                                    top: 6,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step['label'] as String,
                                        style: TextStyle(
                                          fontWeight: isCompleted
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 15,
                                          color: isCompleted
                                              ? const Color(
                                                  0xFF1A1A2E)
                                              : const Color(
                                                  0xFFB0B7C3),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        step['description'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isCompleted
                                              ? const Color(
                                                  0xFF6B7280)
                                              : const Color(
                                                  0xFFB0B7C3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Check mark for completed
                              if (isCompleted && !isCurrent)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF22C55E),
                                    size: 20,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Delivery details
                  if (_order != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEEEFF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _order!.deliveryAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_order!.riderName != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.delivery_dining,
                                  size: 16,
                                  color: Color(0xFF2EC4B6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rider: ${_order!.riderName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Back to home button
                  if (_currentStatus == 'delivered')
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.home),
                        label: const Text('Back to Home'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}