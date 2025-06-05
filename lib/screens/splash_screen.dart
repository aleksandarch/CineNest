import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../boxes/boxes.dart';
import '../models/movie_model.dart';
import '../routes/router_constants.dart';
import '../services/movie_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _initApp(BuildContext context) async {
    final Box<MovieModel> movieBox = Boxes.getMovies();

    if (movieBox.isEmpty) await MovieService.instance.refreshMovies();

    if (context.mounted) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go(RouteConstants.main));
    }
  }

  @override
  Widget build(BuildContext context) {
    _initApp(context);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
