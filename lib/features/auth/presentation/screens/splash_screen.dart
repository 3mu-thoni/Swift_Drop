import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) {
    if (mounted) context.go('/login');
    return;
  }

  final role = await ref.read(authProvider).getSavedRole();
  if (!mounted) return;

  if (role == AppConstants.roleRider) {
    context.go('/rider');
  } else if (role == AppConstants.roleAdmin) {
    context.go('/admin');
  } else {
    context.go('/home');
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFF6B35),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'SwiftDrop',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Delivering happiness',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}