import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;

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
}
