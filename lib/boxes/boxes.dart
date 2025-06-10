import 'package:cine_nest/models/bookmark_model.dart';
import 'package:hive/hive.dart';

import '../models/movie_model.dart';

class Boxes {
  // ------------------ Movies box ------------------
  static Future<Box<MovieModel>> openMovieBox() =>
      Hive.openBox<MovieModel>('MovieBox');

  static Box<MovieModel> getMovies() => Hive.box<MovieModel>('MovieBox');

  static Future<int> clearMovies() => Hive.box<MovieModel>('MovieBox').clear();

  // ------------------ User data box ------------------
  static Future<Box> openUserDataBox() => Hive.openBox('UserData');

  static Box getUserData() => Hive.box('UserData');

  static Future<int> clearUserData() => Hive.box('UserData').clear();

  // ------------------ Bookmark data box ------------------
  static Future<Box<BookmarkModel>> openBookmarkBox() =>
      Hive.openBox<BookmarkModel>('BookmarkBox');

  static Box<BookmarkModel> getBookmarks() =>
      Hive.box<BookmarkModel>('BookmarkBox');

  static Future<int> clearBookmarks() =>
      Hive.box<BookmarkModel>('BookmarkBox').clear();
}
