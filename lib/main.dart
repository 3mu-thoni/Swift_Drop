import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_service.dart';
import 'core/network/socket_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'core/providers/theme_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Only set up push notifications on mobile, not web
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await messaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && fcmToken != null) {
      try {
        final api = ApiService();
        await api.patch('/auth/fcm-token',
            data: {'fcmToken': fcmToken});
      } catch (e) {
        debugPrint('FCM token update error: $e');
      }
    }
  }

  // Auto-sync Firebase user with backend on app start
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    try {
      final api = ApiService();
      final existingToken = await api.getToken();

      if (existingToken == null || existingToken.isEmpty) {
        final response = await api.post('/auth/google', data: {
          'firebaseUid': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName ?? 'User',
          'photoUrl': firebaseUser.photoURL ?? '',
          'role': 'customer',
        });
        await api.saveToken(response.data['token']);
        debugPrint('✅ Token saved on app start');
      }
    } catch (e) {
      debugPrint('Auto-sync error: $e');
    }
  }

  // Connect socket
  SocketService().connect();

  // Listen for foreground messages on mobile only
  if (!kIsWeb) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          '📱 Message: ${message.notification?.title}');
    });
  }

  runApp(
    const ProviderScope(
      child: SwiftDropApp(),
    ),
  );
}

class SwiftDropApp extends ConsumerWidget {
  const SwiftDropApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}