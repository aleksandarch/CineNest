import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';

class Loader extends StatefulWidget {
  final double loaderWidth;
  final Color color;

  const Loader(
      {super.key, this.loaderWidth = 38, this.color = Colors.deepPurple});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: _controller,
        child: SvgPicture.asset('${AppConstants.assetIconsPath}loading.svg',
            colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
            width: widget.loaderWidth));
  }
}
