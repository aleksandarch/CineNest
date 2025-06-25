import 'package:flutter_test/flutter_test.dart';
import 'package:cine_nest/models/movie_model.dart';

void main() {
  test('fromJson parses optional fields correctly', () {
    final json = {
      'id': 'tt1',
      'title': 'Test',
      'year': '2021',
      'genres': ['Drama'],
      'ratings': [1, 2],
      'posterurl': 'url',
      'contentRating': '',
      'duration': '',
      'releaseDate': '2021-01-01',
      'originalTitle': '',
      'storyline': 'Story',
      'actors': ['A'],
      'imdbRating': ''
    };

    final model = MovieModel.fromJson(json);
    expect(model.contentRating, isNull);
    expect(model.duration, isNull);
    expect(model.imdbRating, isNull);
    expect(model.genres, contains('Drama'));
  });
}
