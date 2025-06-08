import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meilisearch/meilisearch.dart';

class MeiliSearchService {
  static final MeiliSearchService _instance = MeiliSearchService._internal();

  factory MeiliSearchService() => _instance;

  late final MeiliSearchClient client;

  MeiliSearchService._internal() {
    client = MeiliSearchClient(
      dotenv.env['MEILISEARCH_HOST_URL'] ?? '',
      dotenv.env['MEILISEARCH_API_KEY'] ?? '',
    );
  }

  MeiliSearchIndex get moviesIndex => client.index('movies');

  Future<List<String>> searchInMovies(
      {required String query, bool useSemantic = true}) async {
    final index = moviesIndex;

    final searchOptions = useSemantic
        ? SearchQuery(
            attributesToRetrieve: ['id'],
            hybrid: HybridSearch(embedder: 'openai', semanticRatio: 0.7))
        : SearchQuery(attributesToRetrieve: ['id']);

    try {
      final Searcheable response = await index.search(query, searchOptions);
      if (response.hits.isNotEmpty) {
        return List<String>.from(
            response.hits.map((hit) => hit['id'].toString()));
      }
    } catch (e) {
      debugPrint('Error during MeiliSearch: $e');
    }
    return [];
  }
}
