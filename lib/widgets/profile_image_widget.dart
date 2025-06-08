import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double height;

  const ProfileImageWidget({super.key, this.imageUrl, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Hero(
        tag: 'user_profile_image',
        child: CachedNetworkImage(
          imageUrl: imageUrl ?? '',
          width: height,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => SkeletonAnimation(
              gradientColor: Colors.deepPurple.shade100,
              shimmerColor: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                  width: height,
                  height: height,
                  color: Colors.deepPurple.shade100)),
          errorWidget: (context, url, error) => Container(
              width: height,
              height: height,
              color: Colors.deepPurple.shade200,
              child: Icon(CupertinoIcons.person,
                  size: (height / 5 * 3), color: Colors.white)),
        ),
      ),
    );
  }
}
