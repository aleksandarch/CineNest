import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/sign_in_bloc.dart';
import '../models/movie_model.dart';
import '../routes/router_constants.dart';
import '../services/bookmark_service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          movie.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () async {
              final bloc = context.read<SignInBloc>();
              if (bloc.isSignedIn) {
                try {
                  await BookmarkService.addBookmark(
                    userId: bloc.currentUser!.uid,
                    movieId: movie.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmarked!')),
                  );
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              } else {
                // Redirect to Login
                context.push(RouteConstants.login);
              }
            },
          ),
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
