import 'package:flutter/material.dart';

import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

class BookmarkBloc extends ChangeNotifier {
  final List<BookmarkModel> _bookmarks = [];

  List<BookmarkModel> get bookmarks => List.unmodifiable(_bookmarks);

  void updateBookmarks(List<BookmarkModel> newBookmarks) {
    _bookmarks
      ..clear()
      ..addAll(newBookmarks);
    notifyListeners();
  }

  bool isBookmarked(String movieId) {
    return _bookmarks.any((bookmark) => bookmark.movieId == movieId);
  }

  Future<void> toggleBookmark(
      {required String userId, required String movieId}) async {
    if (isBookmarked(movieId)) {
      await BookmarkService.removeBookmark(userId: userId, movieId: movieId);
    } else {
      await BookmarkService.addBookmark(userId: userId, movieId: movieId);
    }
  }
}
