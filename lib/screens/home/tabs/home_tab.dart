import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../boxes/boxes.dart';
import '../../../models/movie_model.dart';
import '../../../routes/router_constants.dart';
import '../../../services/movie_service.dart';

class HomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const HomeScreen({super.key, required this.scrollController});

  Future<void> _reloadMovies(BuildContext context) async {
    await MovieService.instance.refreshMovies();
  }

  @override
  Widget build(BuildContext context) {
    final Box<MovieModel> movieBox = Boxes.getMovies();

    return ValueListenableBuilder(
      valueListenable: movieBox.listenable(),
      builder: (context, Box<MovieModel> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No movies found.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _reloadMovies(context),
                  child: const Text('Reload Movies'),
                ),
              ],
            ),
          );
        }

        final movies = box.values.toList();

        return SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              int crossAxisCount =
                  isWide ? 3 : 2; // 3 columns on wide screens, 2 on small

              return GridView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: MediaQuery.of(context).padding.top),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _MovieCard(movie: movie);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${RouteConstants.movieDetails}/${movie.id}');
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: movie.id,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Bookmark logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
