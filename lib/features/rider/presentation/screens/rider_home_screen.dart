import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/rider_provider.dart';
import '../../../../models/order_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AvailableOrdersTab(),
          _MyDeliveriesTab(),
          _RiderProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: const Color(0xFF6B7280),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            activeIcon: Icon(Icons.route),
            label: 'My Deliveries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AvailableOrdersTab extends ConsumerWidget {
  const _AvailableOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(availableOrdersProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Orders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'Accept orders to start delivering',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: Color(0xFF22C55E)),
                      SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: orders.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35)),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orderList) => orderList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delivery_dining_outlined,
                              size: 80, color: Color(0xFFE5E7EB)),
                          SizedBox(height: 16),
                          Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'New orders will appear here',
                            style: TextStyle(
                                color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: orderList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _AvailableOrderCard(
                            order: orderList[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableOrderCard extends ConsumerWidget {
  final OrderModel order;
  const _AvailableOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shopName.isNotEmpty
                        ? order.shopName
                        : 'Shop',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    '${order.items.length} items • KSh ${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'KSh ${order.deliveryFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(riderRepositoryProvider)
                    .acceptOrder(order.id);
                ref.invalidate(availableOrdersProvider);
                ref.invalidate(myDeliveriesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order accepted!'),
                      backgroundColor: Color(0xFF22C55E),
                    ),
                  );
                }
              },
              child: const Text('Accept Order'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyDeliveriesTab extends ConsumerWidget {
  const _MyDeliveriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(myDeliveriesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'My Deliveries',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Expanded(
            child: deliveries.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35)),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orderList) => orderList.isEmpty
                  ? const Center(
                      child: Text(
                        'No active deliveries',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: orderList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orderList[index];
                        return _DeliveryCard(order: order);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  final OrderModel order;
  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.shopName.isNotEmpty ? order.shopName : 'Order',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(riderRepositoryProvider)
                        .markDelivered(order.id);
                    ref.invalidate(myDeliveriesProvider);
                  },
                  child: const Text('Mark Delivered'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiderProfileTab extends ConsumerWidget {
  const _RiderProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delivery_dining,
                size: 80, color: Color(0xFFFF6B35)),
            const SizedBox(height: 16),
            const Text(
              'Rider Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}