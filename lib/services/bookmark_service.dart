import 'package:cloud_firestore/cloud_firestore.dart';

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

  static Stream<List<String>> getBookmarks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
