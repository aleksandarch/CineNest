import 'package:cine_nest/models/movie_model.dart';
import 'package:cine_nest/widgets/movie_poster_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/router_constants.dart';

class NewMovieCard extends StatelessWidget {
  final MovieModel movie;

  const NewMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteConstants.movieDetails}/${movie.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MoviePoster(
              posterUrl: movie.posterUrl, movieId: movie.id, borderRadius: 18),
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
                  child: Icon(
                    false // todo: implement bookmark logic
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: Colors.white,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    movie.genres.isEmpty
                        ? const SizedBox(height: 17)
                        : Text(
                            movie.genres.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
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
    );
  }
}
