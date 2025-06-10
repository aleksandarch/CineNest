import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/movie_model.dart';
import '../../routes/router_constants.dart';
import '../movie_poster.dart';

class StandardMovieCard extends StatelessWidget {
  final MovieModel movie;
  final bool showRating;
  final Widget? additionalWidget;
  final DateTime? addedOn;

  const StandardMovieCard({
    super.key,
    required this.movie,
    this.showRating = true,
    this.additionalWidget,
    this.addedOn,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => context.push('${RouteConstants.movieDetails}/${movie.id}'),
      child: IntrinsicHeight(
        child: Row(
          children: [
            MoviePoster(posterUrl: movie.posterUrl, movieId: movie.id),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (showRating && movie.imdbRating != null)
                    _buildRatingStars(movie.imdbRating!),
                  if (addedOn != null) _buildAddedOn(addedOn!.toLocal()),
                  if (additionalWidget != null) additionalWidget!,
                  Text(movie.storyline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black87)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = (rating / 2).floor(); // imdbRating is 0-10; 5 stars
    bool halfStar = (rating / 2) - fullStars >= 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.deepPurple, size: 16));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.deepPurple, size: 16));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.deepPurple, size: 16));
      }
    }
    return Row(
      children: [
        ...stars,
        const SizedBox(width: 12),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAddedOn(DateTime addedOn) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final addedDate = DateTime(addedOn.year, addedOn.month, addedOn.day);

    String formatted;

    if (addedDate == today) {
      formatted = 'Today ${DateFormat.Hm().format(addedOn)}';
    } else if (addedDate == yesterday) {
      formatted = 'Yesterday ${DateFormat.Hm().format(addedOn)}';
    } else if (now.difference(addedOn).inDays < 7) {
      // Last X day
      formatted =
          'Last ${DateFormat.EEEE().format(addedOn)} ${DateFormat.Hm().format(addedOn)}';
    } else if (now.difference(addedOn).inDays < 365) {
      formatted = DateFormat('dd.MM').format(addedOn);
    } else {
      formatted = 'More than a year ago';
    }

    return Text('Added $formatted',
        style: const TextStyle(color: Colors.black54));
  }
}
