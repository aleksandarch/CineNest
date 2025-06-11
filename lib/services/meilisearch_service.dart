import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MeiliSearchService {
  static final MeiliSearchService _instance = MeiliSearchService._internal();

  factory MeiliSearchService() => _instance;

  final String _baseUrl = dotenv.env['MEILISEARCH_HOST_URL'] ?? '';
  final String _apiKey = dotenv.env['MEILISEARCH_API_KEY'] ?? '';

  MeiliSearchService._internal();

  Future<List<String>> searchInMovies({
    required String query,
    bool useSemantic = true,
  }) async {
    final url = Uri.parse('$_baseUrl/indexes/movies/search');

    // Use semantic search only on non-web platforms
    final Map<String, dynamic> body = {
      'q': query,
      'attributesToRetrieve': ['id'],
    };

    if (useSemantic && !kIsWeb) {
      body['hybrid'] = {
        'embedder': 'openai',
        'semanticRatio': 0.7,
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final hits = decoded['hits'] as List<dynamic>;
        return hits.map((hit) => hit['id'].toString()).toList();
      } else {
        debugPrint(
            'MeiliSearch error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception during MeiliSearch: $e');
    }

    return [];
  }
}
