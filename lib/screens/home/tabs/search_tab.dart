import 'package:cine_nest/constants/constants.dart';
import 'package:cine_nest/models/movie_model.dart';
import 'package:cine_nest/widgets/empty_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../boxes/boxes.dart';
import '../../../services/meilisearch_service.dart';
import '../../../widgets/animated_search_field.dart';
import '../../../widgets/loader.dart';
import '../../../widgets/movie_display_cards/standard_movie_card.dart';

const List<String> keywordSearchHints = [
  'Game Night',
  'solve a murder mystery',
  'Area X: Annihilation',
  'environmental disaster zone',
  'Hannah',
  'grapple with the consequences',
  'The Lodgers',
  'sinister presence',
  'Beast of Burden',
  'illegal cargo',
  'The Chamber',
  'trapped underwater',
  'Survivors Guide to Prison',
  'barbaric the US justice system',
  'Red Sparrow',
  'Russian intelligence officer',
  'Death Wish',
  'burning for revenge',
  'Foxtrot',
  'troubled family face the facts',
  'They Remain',
  'unnatural animal behaviour',
  'Submission',
  'talented young writing student',
  'Souvenir',
  'former singer Laura',
  'Dance Academy: The Movie',
  'dance academy TV show',
  'Ett veck i tiden',
  'travel across the universe',
  'The Strangers: Prey at Night',
  'masked psychopaths',
];

const List<String> semanticSearchHints = [
  'Romantic comedies',
  'Murder mysteries',
  'Feel-good stories',
  'Epic adventures',
  'Edge of your seat',
  'Time-travel movies',
  'Unexpected twists',
  'Tearjerker films',
  'Based on true story',
  'Mind-bending plots',
  'Dystopian futures',
  'Forbidden love',
  'Family-friendly fun',
  'Heist and crime',
  'Legendary heroes',
  'Heartwarming tales',
  'Spine-chilling horror',
  'End-of-world tales',
  'Laugh-out-loud',
  'Coming-of-age',
  'Revenge thrillers',
  'Historical epics',
];

class SearchTab extends StatefulWidget {
  final ScrollController scrollController;

  const SearchTab({super.key, required this.scrollController});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  bool _isLoading = false;
  bool _doSemanticSearch = true;
  final List<MovieModel> _searchResults = [];
  String lastSearched = '';

  @override
  initState() {
    super.initState();
    showAll();
  }

  void showAll() {
    final box = Boxes.getMovies();
    setState(() => _searchResults.addAll(box.values.toList()));
  }

  Future<void> search(String phrase) async {
    lastSearched = phrase;
    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    if (phrase.isEmpty) {
      showAll();
    } else {
      if (_doSemanticSearch) {
        await startSemanticSearch(phrase);
      } else {
        startKeywordSearch(phrase);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> startSemanticSearch(String phrase) async {
    final foundIds = await MeiliSearchService().searchInMovies(query: phrase);
    if (foundIds.isNotEmpty) {
      final box = Boxes.getMovies().values;
      final filteredMovies =
          box.where((movie) => foundIds.contains(movie.id)).toList();

      if (mounted) setState(() => _searchResults.addAll(filteredMovies));
    }
  }

  void startKeywordSearch(String phrase) {
    final box = Boxes.getMovies();
    final lowerPhrase = phrase.toLowerCase();

    final List<MovieModel> filteredMovies = [];

    for (final movie in box.values) {
      final titleMatch = movie.title.toLowerCase().contains(lowerPhrase);
      final storylineMatch =
          movie.storyline.toLowerCase().contains(lowerPhrase);
      final genresMatch = movie.genres.any(
        (genre) => genre.toLowerCase().contains(lowerPhrase),
      );

      if ((titleMatch || storylineMatch || genresMatch)) {
        filteredMovies.add(movie);
      }
    }

    setState(() => _searchResults.addAll(filteredMovies));
  }

  @override
  Widget build(BuildContext context) {
    final saveHorizontalPadding = MediaQuery.of(context).padding.left + 20;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          _buildSearchTypeExplanation(),
          _buildSearchResults()
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: AnimatedTextField(
                    hintTexts: _doSemanticSearch
                        ? (List<String>.from(semanticSearchHints)..shuffle())
                        : (List<String>.from(keywordSearchHints)..shuffle()),
                    onChanged: search)),
            GestureDetector(
              onTap: () {
                setState(() => _doSemanticSearch = !_doSemanticSearch);
                search(lastSearched);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(left: 16),
                width: 50,
                padding: EdgeInsets.only(left: 3, bottom: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.deepPurple
                        .withValues(alpha: _doSemanticSearch ? 1 : 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: _doSemanticSearch ? Colors.deepPurple : Colors.white,
                    end: _doSemanticSearch ? Colors.white : Colors.deepPurple,
                  ),
                  duration: Duration(milliseconds: 200),
                  builder: (context, color, child) {
                    return SvgPicture.asset(
                      '${AppConstants.assetIconsPath}ai.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        color ?? Colors.deepPurple,
                        BlendMode.srcIn,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeExplanation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        _doSemanticSearch
            ? 'Semantic search uses AI to understand you better'
            : 'Keyword search matches your query with exact terms',
        style:
            TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: _isLoading
          ? Center(child: Loader())
          : _searchResults.isEmpty
              ? EmptyPage(title: 'Nothing found with this phrase')
              : GridView.builder(
                  controller: widget.scrollController,
                  padding: EdgeInsets.only(bottom: 100, top: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 1,
                    crossAxisCount:
                        (MediaQuery.of(context).size.width / 500).ceil(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 25,
                  ),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) =>
                      StandardMovieCard(movie: _searchResults[index]),
                ),
    );
  }
}
