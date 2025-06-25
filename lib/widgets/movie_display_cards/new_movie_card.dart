import 'package:cine_nest/models/movie_model.dart';
import 'package:cine_nest/providers/bookmark_provider.dart';
import 'package:cine_nest/widgets/movie_poster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sign_in_provider.dart';
import '../../routes/router_constants.dart';

class NewMovieCard extends ConsumerStatefulWidget {
  final MovieModel movie;

  const NewMovieCard({super.key, required this.movie});

  @override
  ConsumerState<NewMovieCard> createState() => _NewMovieCardState();
}

class _NewMovieCardState extends ConsumerState<NewMovieCard> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final isBookmarked = ref.watch(isBookmarkedProvider(widget.movie.id));

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        context.push('${RouteConstants.movieDetails}/${widget.movie.id}');
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _scale,
        curve: Curves.easeInOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MoviePoster(
              posterUrl: widget.movie.posterUrl,
              movieId: widget.movie.id,
              borderRadius: 18,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        final controller = ref.read(signInProvider.notifier);
                        final isLoggedIn = controller.isSignedIn;
                        if (isLoggedIn) {
                          final bb = ref.read(bookmarkProvider.notifier);
                          bb.toggleBookmark(
                            userId: controller.userId!,
                            movieId: widget.movie.id,
                          );
                        } else {
                          context.push(RouteConstants.login);
                        }
                      },
                      child: Hero(
                        tag: 'bookmark-icon-${widget.movie.id}',
                        child: Icon(
                          isBookmarked
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.movie.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      widget.movie.genres.isEmpty
                          ? const SizedBox(height: 17)
                          : Text(
                              widget.movie.genres.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
