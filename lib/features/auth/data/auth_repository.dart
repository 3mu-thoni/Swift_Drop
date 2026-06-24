import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';

class AuthRepository {
  final _api = ApiService();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Register in Firebase
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);

    // Register in our backend
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });

    final token = response.data['token'];
    await _api.saveToken(token);

    // Save role
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, role);

    return UserModel.fromMap(response.data['user']);
  }

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Sign in Firebase
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Login to our backend
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final token = response.data['token'];
    await _api.saveToken(token);

    final user = UserModel.fromMap(response.data['user']);

    // Save role
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, user.role);

    return user;
  }

  Future<UserModel?> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    // Sync with backend
    final response = await _api.post('/auth/google', data: {
      'firebaseUid': firebaseUser.uid,
      'email': firebaseUser.email,
      'name': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoURL,
      'role': 'customer',
    });

    final token = response.data['token'];
    await _api.saveToken(token);

    final user = UserModel.fromMap(response.data['user']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, user.role);

    return user;
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