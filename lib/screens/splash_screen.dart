import 'package:cine_nest/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../boxes/boxes.dart';
import '../models/movie_model.dart';
import '../routes/router_constants.dart';
import '../services/movie_service.dart';
import '../widgets/loader.dart';

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

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              _buildLogo(),
              Loader(color: Colors.white),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('${AppConstants.assetImagePath}app_icon.png', height: 120),
        const SizedBox(height: 10),
        const Text('CineNest',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(
        'Created for\nEden Tech Labs',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
