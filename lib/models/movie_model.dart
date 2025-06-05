import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String year;
  @HiveField(3)
  List<String> genres;
  @HiveField(4)
  List<int> ratings;
  @HiveField(5)
  String posterUrl;
  @HiveField(6)
  String? contentRating;
  @HiveField(7)
  String? duration;
  @HiveField(8)
  String releaseDate;
  @HiveField(9)
  String? originalTitle;
  @HiveField(10)
  String storyline;
  @HiveField(11)
  List<String> actors;
  @HiveField(12)
  double? imdbRating;

  MovieModel({
    required this.id,
    required this.title,
    required this.year,
    required this.genres,
    required this.ratings,
    required this.posterUrl,
    required this.contentRating,
    required this.duration,
    required this.releaseDate,
    required this.originalTitle,
    required this.storyline,
    required this.actors,
    required this.imdbRating,
  });

  factory MovieModel.fromJson(Map json) {
    return MovieModel(
      id: json['id'],
      title: json['title'],
      year: json['year'],
      genres: List<String>.from(json['genres']),
      ratings: List<int>.from(json['ratings']),
      posterUrl: json['posterurl'],
      contentRating: json['contentRating'] == '' ? null : json['contentRating'],
      duration: json['duration'] == '' ? null : json['duration'],
      releaseDate: json['releaseDate'],
      originalTitle:
          json['originalTitle'] == '' ? null : json['originalTitle'] as String?,
      storyline: json['storyline'] as String,
      actors: List<String>.from(json['actors']),
      imdbRating: json['imdbRating'] == ''
          ? null
          : double.tryParse(json['imdbRating'].toString()),
    );
  }
}
