import 'package:hive/hive.dart';

import '../models/movie_model.dart';

class Boxes {
  static Future<Box<MovieModel>> openMovieBox() =>
      Hive.openBox<MovieModel>('MovieBox');

  static Future<Iterable<int>> addMovies(List<MovieModel> movies) =>
      Hive.box<MovieModel>('MovieBox').addAll(movies);

  static Box<MovieModel> getMovies() => Hive.box<MovieModel>('MovieBox');

  static Future<int> clearMovies() => Hive.box('MovieBox').clear();

  // ------------------ User data box ------------------
  static Future<Box> openUserDataBox() => Hive.openBox('UserData');

  static Box getUserData() => Hive.box('UserData');

  static Future<int> clearUserData() => Hive.box('UserData').clear();
}
