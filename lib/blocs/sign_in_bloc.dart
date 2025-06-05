import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInBloc extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isSignedIn => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _setLoading(false);
      return result.user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Login failed');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return null; // user canceled
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      _setLoading(false);
      return result.user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Google sign-in failed');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUp(String nickname, String email, String password) async {
    _setLoading(true);
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Update displayName
      await result.user?.updateDisplayName(nickname);

      _setLoading(false);
      return result.user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Sign up failed');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to send reset email');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
