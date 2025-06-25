import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cine_nest/providers/sign_in_provider.dart';
import 'package:cine_nest/widgets/empty_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../boxes/boxes.dart';
import '../../../constants/constants.dart';
import '../../../models/movie_model.dart';
import '../../../widgets/movie_display_cards/new_movie_card.dart';
import '../../../widgets/movie_display_cards/standard_movie_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const HomeScreen({super.key, required this.scrollController});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedGenre = 'All';

  @override
  Widget build(BuildContext context) {
    final saveHorizontalPadding = MediaQuery.of(context).padding.left + 20;
    final Box<MovieModel> movieBox = Boxes.getMovies();
    final sb = ref.watch(signInProvider.notifier);

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalute(saveHorizontalPadding, sb),
          ValueListenableBuilder(
            valueListenable: movieBox.listenable(),
            builder: (context, Box<MovieModel> box, _) {
              if (box.isEmpty) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
                  child: EmptyPage(
                      title: 'Error Loading Movies. Please reload.',
                      showReloadButton: true,
                      artificialExpand: true),
                );
              }

              final movies = box.values.toList();

              final filteredByRating = movies
                  .where((movie) =>
                      movie.genres.contains(selectedGenre) ||
                      selectedGenre == 'All')
                  .where((movie) =>
                      movie.imdbRating != null && movie.imdbRating! > 0)
                  .toList()
                ..sort((a, b) => b.imdbRating!.compareTo(a.imdbRating!));

              final genres = movies
                  .expand((movie) => movie.genres)
                  .toSet()
                  .toList()
                ..sort((a, b) => a.compareTo(b));

              final newMovies = movies
                  .where((movie) =>
                      movie.genres.contains(selectedGenre) ||
                      selectedGenre == 'All')
                  .toList()
                ..sort((a, b) => b.releaseDate.compareTo(a.releaseDate))
                ..take(10).toList();

              return Column(
                children: [
                  _buildGenres(genres),
                  _buildNewest(saveHorizontalPadding, newMovies),
                  _buildTopRated(saveHorizontalPadding, filteredByRating),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildSalute(double saveHorizontalPadding, SignInController sb) {
    final now = DateTime.now();

    final Box box = Boxes.getUserData();
    DateTime? lastSaluteDate = box.get('lastSaluteDate') as DateTime?;

    bool greetedToday = false;
    if (lastSaluteDate != null) {
      greetedToday = lastSaluteDate.day == now.day &&
          lastSaluteDate.month == now.month &&
          lastSaluteDate.year == now.year;
    }

    if (!greetedToday) box.put('lastSaluteDate', now);

    final String greetingText;
    bool showAppIcon = false;

    if (greetedToday) {
      showAppIcon = true;
      greetingText = AppConstants.appName;
    } else if (sb.isSignedIn) {
      greetingText = '👋 Hello, ${sb.username ?? 'User'}';
    } else {
      greetingText = 'Welcome to CineNest';
    }

    return Padding(
        padding: EdgeInsets.fromLTRB(
            saveHorizontalPadding, 4, saveHorizontalPadding, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAppIcon)
              Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.asset(
                      '${AppConstants.assetImagePath}app_icon.png',
                      height: 30)),
            Text(greetingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ));
  }

  Widget _buildGenres(List<String> genres) {
    return SizedBox(
        height: 34,
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return GestureDetector(
                    onTap: () => setState(() => selectedGenre = 'All'),
                    child: _buildGenreChip('All', selectedGenre == 'All'));
              }

              final genreName = genres[index - 1];
              return GestureDetector(
                  onTap: () => setState(() => selectedGenre = genreName),
                  child:
                      _buildGenreChip(genreName, selectedGenre == genreName));
            },
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).padding.left + 20),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 10),
            itemCount: genres.length + 1,
            scrollDirection: Axis.horizontal));
  }

  Widget _buildGenreChip(String title, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(minWidth: 80),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple)),
      child: Text(title,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.deepPurple,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNewest(
      double saveHorizontalPadding, List<MovieModel> filteredMovies) {
    double posterHeight = MediaQuery.of(context).size.height * 0.4;
    if (posterHeight < 280) posterHeight = 280;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
            alignment: Alignment.centerLeft,
            child: _sectionTitleWidget('The Newest ')),
        SizedBox(
          height: posterHeight + 40,
          width: posterHeight + 140,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) =>
                NewMovieCard(movie: filteredMovies[index]),
            itemCount: filteredMovies.length,
            layout: SwiperLayout.STACK,
            itemWidth: posterHeight / 1.5,
            itemHeight: posterHeight,
            axisDirection: AxisDirection.right,
            loop: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRated(
      double saveHorizontalPadding, List<MovieModel> filteredMovies) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleWidget('Top Rated '),
          const SizedBox(height: 16),
          filteredMovies.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 140),
                  child: EmptyPage(title: 'No Movies Found'))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 3 / 1,
                      crossAxisCount:
                          (MediaQuery.of(context).size.width / 500).ceil(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 25),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) =>
                      StandardMovieCard(movie: filteredMovies[index]),
                ),
        ],
      ),
    );
  }

  Widget _sectionTitleWidget(String leading) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(leading,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      AnimatedTextKit(
          key: ValueKey(selectedGenre),
          repeatForever: false,
          animatedTexts: [
            TyperAnimatedText(
              selectedGenre == 'All' ? 'Movies' : '$selectedGenre Movies',
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
          totalRepeatCount: 1),
    ]);
  }
}
