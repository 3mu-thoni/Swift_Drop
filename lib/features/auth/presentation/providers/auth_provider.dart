import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userRoleProvider = StateProvider<String>((ref) {
  return AppConstants.roleCustomer;
});

final authProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final _api = ApiService();

  AuthService(this._ref);

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      final firebaseUser = credential.user!;
      final response = await _api.post('/auth/google', data: {
        'firebaseUid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ??
            email.split('@')[0],
        'photoUrl': firebaseUser.photoURL ?? '',
        'role': 'customer',
      });
      await _api.saveToken(response.data['token']);
      debugPrint('✅ Token saved after email login');

      final user = response.data['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.keyUserRole, user['role']);
      _ref.read(userRoleProvider.notifier).state =
          user['role'];
    } catch (e) {
      debugPrint('Backend sync error: $e');
    }

    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name);

    try {
      final firebaseUser = credential.user!;
      final response = await _api.post('/auth/google', data: {
        'firebaseUid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': name,
        'photoUrl': firebaseUser.photoURL ?? '',
        'role': role,
      });
      await _api.saveToken(response.data['token']);
      debugPrint('✅ Token saved after registration');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, role);
      _ref.read(userRoleProvider.notifier).state = role;
    } catch (e) {
      debugPrint('Backend register error: $e');
    }

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Use googleUser directly — avoids People API call
      final email = googleUser.email;
      final name =
          googleUser.displayName ?? email.split('@')[0];
      final photoUrl = googleUser.photoUrl ?? '';

      try {
        final response =
            await _api.post('/auth/google', data: {
          'firebaseUid': firebaseUser.uid,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'role': 'customer',
        });
        await _api.saveToken(response.data['token']);
        debugPrint('✅ Token saved after Google login');

        final user = response.data['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            AppConstants.keyUserRole, user['role']);
        _ref.read(userRoleProvider.notifier).state =
            user['role'];
      } catch (e) {
        debugPrint('Google backend sync error: $e');
      }

      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserRole);
  }

  Future<String> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole) ??
        AppConstants.roleCustomer;
  }
}