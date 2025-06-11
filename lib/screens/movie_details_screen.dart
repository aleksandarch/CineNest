import 'dart:io';
import 'dart:ui';

import 'package:cine_nest/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/bookmark_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/movie_model.dart';
import '../routes/router_constants.dart';
import '../widgets/actor_card.dart';
import '../widgets/content_rating_info.dart';
import '../widgets/movie_poster.dart';
import '../widgets/rating_gauge.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledEnough = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset = _scrollController.offset;

    final isNowScrolledEnough = scrollOffset > screenHeight * 0.45;

    if (_isScrolledEnough != isNowScrolledEnough) {
      setState(() {
        _isScrolledEnough = isNowScrolledEnough;
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(children: [
            _buildMoviePoster(context),
            _buildMovieData(context),
          ]),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    final sb = context.read<SignInBloc>();
    final bb = context.watch<BookmarkBloc>();
    final isBookmarked = bb.isBookmarked(widget.movie.id);

    final iconColor = _isScrolledEnough ? Colors.black : Colors.white;

    void onBookmarkToggle(BuildContext context) {
      if (sb.isSignedIn) {
        bb.toggleBookmark(userId: sb.userId!, movieId: widget.movie.id);
      } else {
        context.push(RouteConstants.login);
      }
    }

    return AppBar(
      backgroundColor: _isScrolledEnough
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.adaptive.arrow_back, color: iconColor),
          onPressed: () => context.pop()),
      actions: [
        IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Hero(
                tag: 'bookmark-icon-${widget.movie.id}',
                child: Icon(
                    isBookmarked
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: iconColor)),
            onPressed: () => onBookmarkToggle(context)),
      ],
    );
  }

  Widget _buildMoviePoster(BuildContext context) {
    final double posterHeight = MediaQuery.of(context).size.height * 0.6;

    return SizedBox(
      width: double.infinity,
      height: posterHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Image.network(widget.movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox()))),
          Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade200,
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Theme.of(context)
                          .scaffoldBackgroundColor
                          .withValues(alpha: 0.1),
                      Theme.of(context).scaffoldBackgroundColor
                    ]),
              )),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20),
            child: Column(
              children: [
                Flexible(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: MoviePoster(
                            posterUrl: widget.movie.posterUrl,
                            movieId: widget.movie.id,
                            posterHeight: posterHeight * 0.72,
                            borderRadius: 16))),
                const SizedBox(height: 20),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      widget.movie.genres.length,
                      (index) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.deepPurple)),
                          child: Text(widget.movie.genres[index],
                              style:
                                  const TextStyle(color: Colors.deepPurple))),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieData(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MediaQuery.of(context).size.width > 700
              ? _tabletView()
              : _mobileView()),
    );
  }

  Widget _tabletView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mainTitle(),
        const SizedBox(height: 30),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoryline(),
                      const SizedBox(height: 20),
                      _buildCastAndCrew(),
                    ]),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                width: 1,
                height: 200,
                color: Colors.deepPurple.shade200,
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildMoreInfo()]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _mainTitle(),
      Divider(color: Colors.deepPurple.shade200, height: 30),
      _buildStoryline(),
      Divider(color: Colors.deepPurple.shade200, height: 30),
      _buildCastAndCrew(),
      Divider(color: Colors.deepPurple.shade200, height: 30),
      _buildMoreInfo()
    ]);
  }

  Widget _mainTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(widget.movie.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        if (widget.movie.originalTitle != null)
          Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('(${widget.movie.originalTitle})',
                  style: const TextStyle(fontSize: 16))),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.movie.year,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold)),
            if (widget.movie.contentRating != null)
              ContentRatingInfo(contentRating: widget.movie.contentRating!),
          ],
        ),
      ],
    );
  }

  Widget _buildStoryline() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Storyline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(widget.movie.storyline),
      ],
    );
  }

  Widget _buildCastAndCrew() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.movie.actors.isNotEmpty) ...[
            const Text('Cast',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 10,
                children: widget.movie.actors
                    .map((actor) => WikipediaSearchButton(actorName: actor))
                    .toList()),
          ],
        ]);
  }

  Widget _buildMoreInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('More Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        if (widget.movie.releaseDate.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Release: '),
              Text(formatReleaseDate(widget.movie.releaseDate),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],

        if (widget.movie.duration != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Duration: '),
              Text(formatIsoDuration(widget.movie.duration!),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],

        // Content Rating and IMDb Rating
        if (widget.movie.imdbRating != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset('${AppConstants.assetImagePath}imbd_logo.png',
                  height: 20),
              const SizedBox(width: 6),
              Text('${widget.movie.imdbRating}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(' | 10', style: TextStyle(color: Colors.black54)),
            ],
          )
        ],
        _buildRatingGauge(),
      ],
    );
  }

  Widget _buildRatingGauge() {
    final double rating = widget.movie.ratings.isNotEmpty
        ? widget.movie.ratings.reduce((a, b) => a + b) /
            widget.movie.ratings.length
        : 0.0;
    final int totalVotes = widget.movie.ratings.length;
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: RatingGauge(rating: rating, totalVotes: totalVotes));
  }

  String formatReleaseDate(String date) {
    final dateTime = DateTime.tryParse(date);
    if (dateTime != null) {
      return '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.year}';
    }
    return date;
  }

  String formatIsoDuration(String iso) {
    final regex = RegExp(r'^PT(\d+)M$');
    final match = regex.firstMatch(iso);

    if (match != null) {
      final totalMinutes = int.tryParse(match.group(1)!);
      if (totalMinutes != null) {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        if (hours > 0) {
          return '${hours}h ${minutes}m';
        } else {
          return '${minutes}m';
        }
      }
    }

    return 'Unknown';
  }
}
