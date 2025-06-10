import 'dart:io';

import 'package:cine_nest/boxes/boxes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../routes/router_constants.dart';
import '../services/bookmark_service.dart';
import 'bookmark_bloc.dart';

class SignInBloc extends ChangeNotifier {
  SignInBloc() {
    _authStateChanges.listen((user) {
      if (user == null) {
        _handleSignOutCleanup();
      } else {
        _updateUserInfo(user);
      }
    });
  }

  final _store = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _userId;
  String? get userId => _userId;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _username;
  String? get username => _username;

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  User? get currentUser => _auth.currentUser;

  static Stream<User?> get _authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _updateUserInfo(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential result = await _auth.signInWithCredential(credential);
      _updateUserInfo(result.user);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<User?> signUp(String nickname, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = result.user;
      if (user != null) {
        if (user.displayName == null || user.displayName!.isEmpty) {
          // 1. Update Firebase Auth display name if not set
          await user.updateDisplayName(nickname);
          await user.reload();
        }

        _updateUserInfo(_auth.currentUser);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final storageRef = _store.ref().child('user_profiles/$_userId.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
    }
    return false;
  }

  Future<void> signOut(BuildContext context) async {
    Provider.of<BookmarkBloc>(context, listen: false).clear();

    await _auth.signOut();
    await _googleSignIn.signOut();
    await _clearUserInfo();

    notifyListeners();
    if (context.mounted) context.replace(RouteConstants.main);
  }

  Future<void> _handleSignOutCleanup() async {
    BookmarkService.unsubscribe();
    await Boxes.clearBookmarks();

    await _clearUserInfo();
    notifyListeners();
  }

  Future<bool> deleteAccount(BuildContext context, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Re-authenticate
      final cred =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      await _auth.currentUser?.delete();
      await _clearUserInfo();

      if (context.mounted) {
        Provider.of<BookmarkBloc>(context, listen: false).clear();
      }

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
    }
    return false;
  }

  Future<void> refreshUser() async {
    await _auth.currentUser?.reload();
    _updateUserInfo(_auth.currentUser);
  }

  Future<void> _updateUserInfo(User? user) async {
    if (user != null) {
      _userId = user.uid;
      _userEmail = user.email;
      _username = user.displayName;
      _profileImageUrl = user.photoURL;
      _isSignedIn = true;
    } else {
      await _clearUserInfo();
    }
    notifyListeners();
  }

  Future<void> _clearUserInfo() async {
    _userId = null;
    _userEmail = null;
    _username = null;
    _profileImageUrl = null;
    _isSignedIn = false;
    await Boxes.clearUserData();
  }
}
