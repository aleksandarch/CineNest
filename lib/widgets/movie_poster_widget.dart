import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class MoviePoster extends StatelessWidget {
  final String posterUrl;
  final String movieId;
  final double borderRadius;

  const MoviePoster(
      {super.key,
      required this.posterUrl,
      required this.movieId,
      this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    final posterWidth = 100.0;
    final posterHeight = posterWidth * 1.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Hero(
        tag: 'movie-poster-$movieId',
        child: CachedNetworkImage(
          imageUrl: posterUrl,
          width: posterWidth,
          height: posterHeight,
          fit: BoxFit.cover,
          placeholder: (context, url) => SkeletonAnimation(
              gradientColor: Colors.deepPurple.shade100,
              shimmerColor: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                  width: posterWidth,
                  height: posterHeight,
                  color: Colors.deepPurple.shade100)),
          errorWidget: (context, url, error) => Container(
            width: posterWidth,
            height: posterHeight,
            color: Colors.deepPurple.shade200,
            child:
                Icon(CupertinoIcons.paintbrush, size: 50, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
