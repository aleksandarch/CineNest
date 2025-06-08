import 'package:flutter/material.dart';

import '../models/bookmark_model.dart';

class BookmarkBloc extends ChangeNotifier {
  List<BookmarkModel> _bookmarks = [];

  List<BookmarkModel> get bookmarks => _bookmarks;

  void updateBookmarks(List<BookmarkModel> newBookmarks) {
    _bookmarks = newBookmarks;
    notifyListeners();
  }

  bool isBookmarked(String movieId) {
    return _bookmarks.any((bookmark) => bookmark.movieId == movieId);
  }
}
