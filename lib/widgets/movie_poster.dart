import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class MoviePoster extends StatelessWidget {
  final String posterUrl;
  final String movieId;
  final double borderRadius;
  final double? posterHeight;

  const MoviePoster(
      {super.key,
      required this.posterUrl,
      required this.movieId,
      this.borderRadius = 8,
      this.posterHeight});

  @override
  Widget build(BuildContext context) {
    double pWidth = 100.0;
    double pHeight = pWidth * 1.5;

    if (posterHeight != null) {
      pHeight = posterHeight!;
      pWidth = posterHeight! * 3 / 5;
    }

    return Hero(
      tag: 'movie-poster-$movieId',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          useOldImageOnUrlChange: kIsWeb,
          imageUrl: posterUrl,
          height: pHeight,
          width: posterHeight == null ? pWidth : null,
          fit: BoxFit.cover,
          placeholder: (context, url) => SkeletonAnimation(
              gradientColor: Colors.deepPurple.shade100,
              shimmerColor: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                  width: pWidth,
                  height: pHeight,
                  color: Colors.deepPurple.shade100)),
          errorWidget: (context, url, error) => Container(
            width: pWidth,
            height: pHeight,
            color: Colors.deepPurple.shade200,
            child:
                Icon(CupertinoIcons.paintbrush, size: 50, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
