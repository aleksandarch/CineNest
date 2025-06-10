import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../blocs/bookmark_bloc.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;
  static StreamSubscription? _subscription;

  static Future<bool> addBookmark(
      {required String userId, required String movieId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(movieId)
          .set({'addedOn': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      debugPrint('Failed to add bookmark: $e');
    }
    return false;
  }

  static Future<bool> removeBookmark(
      {required String userId, required String movieId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(movieId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
    }
    return false;
  }

  static void subscribeToBookmarks(String userId, BookmarkBloc notifier) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('addedOn', descending: true)
        .snapshots()
        .listen((snapshot) {
      final bookmarks =
          snapshot.docs.map((doc) => BookmarkModel.fromFirestore(doc)).toList();
      notifier.updateBookmarks(bookmarks);
    });
  }

  static void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
