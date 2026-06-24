import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_service.dart';
import 'admin_shops_screen.dart';
import 'admin_analytics_screen.dart';


// Admin dashboard data provider
final adminDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.get('/admin/dashboard');
  return response.data;
});

final adminUsersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.get('/admin/users');
  return response.data;
});

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _OrdersTab(),
          _ShopsTab(),
          _UsersTab(),
          _AnalyticsTab(),
          _AdminProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ), 

          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Shops',
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
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

// ── Dashboard Tab ──
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'SwiftDrop management',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            dashboard.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35)),
              ),
              error: (e, _) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 12),
                    Text('Error: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(adminDashboardProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (data) {
                final stats = data['stats'] as Map<String, dynamic>;
                final recentOrders =
                    data['recentOrders'] as List<dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Orders',
                          value: '${stats['totalOrders'] ?? 0}',
                          icon: Icons.receipt_long,
                          color: const Color(0xFF3B82F6),
                        ),
                        _StatCard(
                          title: 'Total Users',
                          value: '${stats['totalUsers'] ?? 0}',
                          icon: Icons.people,
                          color: const Color(0xFF8B5CF6),
                        ),
                        _StatCard(
                          title: 'Total Shops',
                          value: '${stats['totalShops'] ?? 0}',
                          icon: Icons.store,
                          color: const Color(0xFF2EC4B6),
                        ),
                        _StatCard(
                          title: 'Revenue',
                          value:
                              'KSh ${stats['revenue'] ?? 0}',
                          icon: Icons.attach_money,
                          color: const Color(0xFF22C55E),
                        ),
                        _StatCard(
                          title: 'Pending',
                          value:
                              '${stats['pendingOrders'] ?? 0}',
                          icon: Icons.pending_actions,
                          color: const Color(0xFFF59E0B),
                        ),
                        _StatCard(
                          title: 'Delivered',
                          value:
                              '${stats['deliveredOrders'] ?? 0}',
                          icon: Icons.check_circle,
                          color: const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent orders
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (recentOrders.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No orders yet',
                            style:
                                TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: recentOrders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _AdminOrderCard(
                              order: recentOrders[index],
                              ref: ref);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orders Tab ──
class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'All Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Expanded(
            child: dashboard.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35)),
              ),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              data: (data) {
                final orders =
                    data['recentOrders'] as List<dynamic>;
                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders yet',
                      style:
                          TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _AdminOrderCard(
                        order: orders[index], ref: ref);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Users Tab ──
class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'All Users',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Expanded(
            child: users.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35)),
              ),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              data: (userList) => userList.isEmpty
                  ? const Center(
                      child: Text('No users found'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: userList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = userList[index];
                        return _UserCard(
                            user: user, ref: ref);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Admin Profile Tab ──
class _AdminProfileTab extends ConsumerWidget {
  const _AdminProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Admin',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Administrator',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),
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

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Admin Order Card ──
class _AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final WidgetRef ref;

  const _AdminOrderCard({
    required this.order,
    required this.ref,
  });

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

  Future<void> _updateStatus(
      BuildContext context, String orderId, String status) async {
    try {
      final api = ApiService();
      await api.patch('/orders/$orderId/status',
          data: {'status': status});
      ref.invalidate(adminDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $status'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final customer = order['customer'];
    final shop = order['shop'];
    final orderId = order['_id'] ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${orderId.toString().substring(orderId.length > 6 ? orderId.length - 6 : 0).toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (customer is Map)
            Text(
              'Customer: ${customer['name'] ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          if (shop is Map)
            Text(
              'Shop: ${shop['name'] ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          Text(
            'Total: KSh ${order['total'] ?? 0}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),

          // Status update buttons
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(
                          context, orderId, 'confirmed'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(
                          context, orderId, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (status == 'confirmed')
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: () =>
                    _updateStatus(context, orderId, 'preparing'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mark Preparing',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          if (status == 'preparing')
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                onPressed: () =>
                    _updateStatus(context, orderId, 'on_the_way'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF2EC4B6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Out for Delivery',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── User Card ──
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final WidgetRef ref;

  const _UserCard({required this.user, required this.ref});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFFEF4444);
      case 'rider': return const Color(0xFF3B82F6);
      default: return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = user['role'] ?? 'customer';
    final roleColor = _roleColor(role);
    final isActive = user['isActive'] ?? true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              role == 'rider'
                  ? Icons.delivery_dining
                  : role == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person,
              color: roleColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
}
class _ShopsTab extends StatelessWidget {
  const _ShopsTab();

  @override
  Widget build(BuildContext context) {
    return const AdminShopsScreen();
  }
}
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return const AdminAnalyticsScreen();
  }
}