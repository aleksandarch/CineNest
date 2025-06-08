import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../blocs/bookmark_bloc.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> addBookmark({
    required String userId,
    required String movieId,
  }) async {
    try {
      print(movieId);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(movieId)
          .set({
        'addedOn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  static Future<void> removeBookmark({
    required String userId,
    required String movieId,
  }) async {
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

  static Stream<List<BookmarkModel>> getBookmarks(String userId) {
    return _firestore
        .collection('bookmarks')
        .doc(userId)
        .collection('userBookmarks')
        .orderBy('createdOn', descending: true) // optional: show newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookmarkModel.fromFirestore(doc))
            .toList());
  }

  static StreamSubscription? _subscription;

  static void subscribeToBookmarks(String userId, BookmarkBloc notifier) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('bookmarks')
        .doc(userId)
        .collection('userBookmarks')
        .orderBy('createdOn', descending: true)
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
