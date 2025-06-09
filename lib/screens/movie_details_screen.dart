import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/bookmark_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/movie_model.dart';
import '../routes/router_constants.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  void _onBookmarkToggle(BuildContext context, SignInBloc sb, BookmarkBloc bb) {
    if (sb.isSignedIn) {
      bb.toggleBookmark(userId: sb.userId!, movieId: movie.id);
    } else {
      context.push(RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.read<SignInBloc>();
    final bb = context.watch<BookmarkBloc>();
    final isBookmarked = bb.isBookmarked(movie.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(isBookmarked
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark),
              onPressed: () => _onBookmarkToggle(context, sb, bb)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: movie.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie.posterUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              movie.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Release Date and Duration
            Row(
              children: [
                if (movie.releaseDate.isNotEmpty)
                  Text('Release: ${movie.releaseDate}'),
                if (movie.duration != null) ...[
                  const SizedBox(width: 16),
                  Text('Duration: ${movie.duration}'),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Content Rating and IMDb Rating
            Row(
              children: [
                if (movie.contentRating != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(movie.contentRating!),
                  ),
                if (movie.imdbRating != null) ...[
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${movie.imdbRating}/10'),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Genres
            Wrap(
              spacing: 8,
              children: movie.genres.map((genre) {
                return Chip(
                  label: Text(genre),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Storyline
            if (movie.storyline.isNotEmpty) ...[
              const Text(
                'Storyline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(movie.storyline),
            ],

            const SizedBox(height: 16),

            // Actors
            if (movie.actors.isNotEmpty) ...[
              const Text(
                'Cast',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: movie.actors.map((actor) {
                  return Chip(
                    label: Text(actor),
                    backgroundColor: Colors.green.shade100,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Ratings list
            if (movie.ratings.isNotEmpty) ...[
              const Text(
                'Ratings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: movie.ratings.map((rating) {
                  return Chip(
                    label: Text('$rating/10'),
                    backgroundColor: Colors.orange.shade100,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
