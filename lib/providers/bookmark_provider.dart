import 'dart:async';

import 'package:cine_nest/boxes/boxes.dart';
import 'package:cine_nest/models/bookmark_model.dart';
import 'package:cine_nest/services/bookmark_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookmarkProvider =
    NotifierProvider<BookmarkNotifier, List<BookmarkModel>>(
        BookmarkNotifier.new);

final isBookmarkedProvider = Provider.family<bool, String>((ref, movieId) {
  final bookmarks = ref.watch(bookmarkProvider);
  return bookmarks.any((b) => b.movieId == movieId);
});

class BookmarkNotifier extends Notifier<List<BookmarkModel>> {
  final _box = Boxes.getBookmarks();
  StreamSubscription? _subscription;

  @override
  List<BookmarkModel> build() => _box.values.toList();

  void startSync(String userId) {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('addedOn', descending: true)
        .snapshots()
        .listen((snapshot) {
      final bookmarks =
          snapshot.docs.map((doc) => BookmarkModel.fromFirestore(doc)).toList();
      updateBookmarks(bookmarks);
    });
  }

  void stopSync() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> updateBookmarks(List<BookmarkModel> firestoreBookmarks) async {
    await _box.clear();
    for (final bookmark in firestoreBookmarks) {
      await _box.put(bookmark.movieId, bookmark);
    }
    _refreshState();
  }

  void toggleBookmark({required String userId, required String movieId}) {
    final existing = state.firstWhere(
      (b) => b.movieId == movieId,
      orElse: () => BookmarkModel(movieId: movieId, createdOn: DateTime.now()),
    );

    if (state.any((b) => b.movieId == movieId)) {
      _removeBookmark(userId, existing);
    } else {
      _addBookmark(userId, existing);
    }
  }

  Future<void> _addBookmark(String userId, BookmarkModel bookmark) async {
    await _box.put(bookmark.movieId, bookmark);
    final success = await BookmarkService.addBookmark(
        userId: userId, movieId: bookmark.movieId);
    if (!success) await _box.delete(bookmark.movieId);

    _refreshState();
  }

  Future<void> _removeBookmark(String userId, BookmarkModel bookmark) async {
    await _box.delete(bookmark.movieId);
    final success = await BookmarkService.removeBookmark(
        userId: userId, movieId: bookmark.movieId);
    if (!success) await _box.put(bookmark.movieId, bookmark);

    _refreshState();
  }

  Future<void> clear() async {
    stopSync();
    await _box.clear();
    _refreshState();
  }

  void _refreshState() => state = _box.values.toList();
}
