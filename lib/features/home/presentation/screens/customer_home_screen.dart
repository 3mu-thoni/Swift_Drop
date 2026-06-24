import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../shop/presentation/providers/shop_provider.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../../core/widgets/notification_banner.dart';
import '../../../../core/widgets/image_picker_widget.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../models/shop_model.dart';
import '../../../../models/product_model.dart';
import '../../../profile/presentation/screens/help_support_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends ConsumerState<CustomerHomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All', 'Food', 'Groceries', 'Pharmacy',
    'Electronics', 'Fashion', 'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    if (kIsWeb) return;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      final notification = message.notification;
      if (notification != null) {
        NotificationBanner.show(
          context,
          title: notification.title ?? 'SwiftDrop',
          message: notification.body ?? '',
          color: const Color(0xFFFF6B35),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final shops = ref.watch(shopsProvider);
    final featured = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(
            cartCount,
            user?.displayName ?? 'there',
            shops,
            featured,
          ),
          _buildSearchTab(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(cartCount),
    );
  }

  Widget _buildHomeTab(
    int cartCount,
    String userName,
    AsyncValue<List<ShopModel>> shops,
    AsyncValue<List<ProductModel>> featured,
  ) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFFFF6B35)),
                            SizedBox(width: 4),
                            Text(
                              'Nairobi, Kenya',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cart icon with badge
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE5E7EB)),
                        ),
                        child: IconButton(
                          icon: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 20),
                          onPressed: () => context.go('/cart'),
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state =
                      value;
                },
                decoration: InputDecoration(
                  hintText: 'Search shops or products...',
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF6B7280)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(searchQueryProvider.notifier)
                                .state = '';
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFFF6B35), width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Promo banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B35),
                      Color(0xFFFF8C61)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Free delivery\non first order!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Order now',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.delivery_dining,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories label
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),

          // Categories list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected =
                      ref.watch(selectedCategoryProvider) ==
                          cat;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedCategoryProvider
                              .notifier)
                          .state = cat;
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFF6B35)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFFF6B35)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Featured label
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Featured',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),

          // Featured products
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: featured.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35)),
                ),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
                data: (products) => products.isEmpty
                    ? const Center(
                        child: Text('No products yet'),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return _ProductCard(
                              product: products[index]);
                        },
                      ),
              ),
            ),
          ),

          // Shops near you label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 24, 20, 12),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shops near you',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  shops
                          .whenData((s) => Text(
                                '${s.length} found',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ))
                          .value ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // Shops list
          SliverToBoxAdapter(
            child: shops.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35)),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Text('Error loading shops: $e')),
              ),
              data: (shopList) => shopList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No shops found',
                          style: TextStyle(
                              color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 20),
                      itemCount: shopList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ShopCard(
                            shop: shopList[index]);
                      },
                    ),
            ),
          ),

          const SliverToBoxAdapter(
              child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search shops or products...',
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF6B7280)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFFF6B35), width: 2),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state =
                    value;
              },
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Type to search shops and products',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const OrdersScreen();
  }

  Widget _buildProfileTab() {
    final user = ref.watch(authStateProvider).valueOrNull;
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile photo with upload
            ImagePickerWidget(
              currentImageUrl: user?.photoURL,
              folder: 'profiles',
              isCircle: true,
              size: 80,
              onImageUploaded: (url) async {
                try {
                  final api = ApiService();
                  await api.patch('/auth/profile',
                      data: {'photoUrl': url});
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo updated'),
                        backgroundColor: Color(0xFF22C55E),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Upload failed: $e'),
                        backgroundColor:
                            const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            _ProfileMenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'My Orders',
              onTap: () =>
                  setState(() => _currentIndex = 2),
            ),
            _ProfileMenuItem(
              icon: Icons.location_on_outlined,
              label: 'Saved Addresses',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen(),
                ),
              ),
            ),

            // Theme toggle
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFEEEFF2)),
              ),
              child: ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: const Color(0xFFFF6B35),
                ),
                title: Text(
                  themeMode == ThemeMode.dark
                      ? 'Light Mode'
                      : 'Dark Mode',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                trailing: SizedBox(
                  width: 50,
                  child: Switch(
                    value: themeMode == ThemeMode.dark,
                    activeThumbColor: const Color(0xFFFF6B35),
                    onChanged: (_) => ref
                        .read(themeProvider.notifier)
                        .toggleTheme(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider).signOut();
                  if (mounted) context.go('/login');
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

  Widget _buildBottomNav(int cartCount) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFEEEFF2))),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) =>
            setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: const Color(0xFF6B7280),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.receipt_long_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Profile menu item ──
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF6B35)),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Color(0xFF6B7280)),
        onTap: onTap,
      ),
    );
  }
}

// ── Product card ──
class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.fastfood_outlined,
                          size: 40,
                          color: const Color(0xFFFF6B35)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.fastfood_outlined,
                      size: 40,
                      color: const Color(0xFFFF6B35)
                          .withValues(alpha: 0.5),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'KSh ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(cartProvider.notifier)
                          .addItem(product);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name} added to cart'),
                          duration:
                              const Duration(seconds: 1),
                          backgroundColor:
                              const Color(0xFF22C55E),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shop card ──
class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                shop.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(
                                top: Radius.circular(16)),
                        child: Image.network(
                          shop.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 120,
                          errorBuilder: (_, __, ___) =>
                              Center(
                            child: Icon(
                              Icons.store_outlined,
                              size: 50,
                              color: const Color(0xFFFF6B35)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.store_outlined,
                          size: 50,
                          color: const Color(0xFFFF6B35)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                if (!shop.isOpen)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Text(
                        'Closed',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12,
                            color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        shop.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 13,
                        color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      shop.deliveryTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.delivery_dining,
                        size: 13,
                        color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      shop.deliveryFee == 0
                          ? 'Free delivery'
                          : 'KSh ${shop.deliveryFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: shop.deliveryFee == 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF6B7280),
                        fontWeight: shop.deliveryFee == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}