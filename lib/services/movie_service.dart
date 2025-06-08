import 'dart:convert';

import 'package:cine_nest/models/movie_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../boxes/boxes.dart';
import '../constants/constants.dart';

class MovieService {
  MovieService._privateConstructor();

  static final MovieService _instance = MovieService._privateConstructor();

  static MovieService get instance => _instance;

  Future<List<MovieModel>> _fetchMovies() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.moviesApiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MovieModel> movies =
            data.map((json) => MovieModel.fromJson(json)).toList();
        return movies;
      } else {
        debugPrint('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
    }
    return [];
  }

  Future<void> refreshMovies({bool toEmptyBox = false}) async {
    try {
      if (toEmptyBox) {
        final Box<MovieModel> movieBox = Boxes.getMovies();
        await movieBox.clear();
      }

      final List<MovieModel> movies = await _fetchMovies();
      await Boxes.addMovies(movies);
    } catch (e) {
      debugPrint('Failed to refresh movies: $e');
    }
  }
}
