import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../blocs/bookmark_bloc.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;
  static StreamSubscription? _subscription;

  static Future<void> addBookmark(
      {required String userId, required String movieId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(movieId)
          .set({'addedOn': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  static Future<void> removeBookmark(
      {required String userId, required String movieId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(movieId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  static void subscribeToBookmarks(String userId, BookmarkBloc notifier) {
    print('SUBSCRIBE TO BOOKMARKS: $userId');
    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('addedOn', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('BOOKMARKS UPDATED: ${snapshot.docs.length}');
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
