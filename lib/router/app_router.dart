import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/screens/customer_home_screen.dart';
import '../features/rider/presentation/screens/rider_home_screen.dart';
import '../features/admin/presentation/screens/admin_home_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/orders/presentation/screens/order_success_screen.dart';
import '../features/tracking/presentation/screens/tracking_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isOnAuth) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order-success/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']  ?? '';
          return OrderSuccessScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return OrderSuccessScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/rider',
        builder: (context, state) => const RiderHomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
  path: '/tracking/:orderId',
  builder: (context, state) {
    final orderId = state.pathParameters['orderId'] ?? '';
    return TrackingScreen(orderId: orderId);
  },
),
    ],
  );
});