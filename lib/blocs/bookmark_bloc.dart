import 'package:cine_nest/boxes/boxes.dart';
import 'package:flutter/material.dart';

import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

class BookmarkBloc extends ChangeNotifier {
  final _box = Boxes.getBookmarks();

  List<BookmarkModel> get bookmarks => _box.values.toList();

  Future<void> updateBookmarks(List<BookmarkModel> firestoreBookmarks) async {
    await _box.clear();
    for (var bookmark in firestoreBookmarks) {
      await _box.put(bookmark.movieId, bookmark);
    }

    notifyListeners();
  }

  Future<void> _addBookmark(String userId, BookmarkModel bookmark) async {
    await _box.put(bookmark.movieId, bookmark);

    final isSuccessful = await BookmarkService.addBookmark(
        userId: userId, movieId: bookmark.movieId);
    if (!isSuccessful) await _box.delete(bookmark.movieId);

    notifyListeners();
  }

  Future<void> _removeBookmark(String userId, BookmarkModel bookmark) async {
    await _box.delete(bookmark.movieId);

    final isSuccessful = await BookmarkService.removeBookmark(
        userId: userId, movieId: bookmark.movieId);
    if (!isSuccessful) _box.put(bookmark.movieId, bookmark);

    notifyListeners();
  }

  void toggleBookmark({required String userId, required String movieId}) {
    final bookmark = bookmarks.firstWhere(
      (bookmark) => bookmark.movieId == movieId,
      orElse: () => BookmarkModel(movieId: movieId, createdOn: DateTime.now()),
    );

    if (isBookmarked(movieId)) {
      _removeBookmark(userId, bookmark);
    } else {
      _addBookmark(userId, bookmark);
    }
  }

  bool isBookmarked(String movieId) => _box.containsKey(movieId);

  Future<void> clear() async {
    BookmarkService.unsubscribe();
    await _box.clear();

    notifyListeners();
  }
}
