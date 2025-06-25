import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../boxes/boxes.dart';
import '../providers/sign_in_provider.dart';
import '../screens/404_screen.dart';
import '../screens/authentication/forgot_password_screen.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/signup_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/movie_details_screen.dart';
import '../screens/splash_screen.dart';
import 'router_constants.dart';

class AppRoutes {
  static final router = GoRouter(
      initialLocation: '/',
      routes: _getRoutes(),
      redirect: _redirectLogic,
      errorBuilder: (context, state) => const NotFoundScreen());

  static List<RouteBase> _getRoutes() => [
        GoRoute(
            path: RouteConstants.splash,
            builder: (context, state) => const SplashScreen()),
        GoRoute(
            path: RouteConstants.login,
            builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: RouteConstants.signup,
            builder: (context, state) => const SignupScreen()),
        GoRoute(
            path: RouteConstants.forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(
            path: RouteConstants.main,
            builder: (context, state) => const MainScreen()),
        GoRoute(
            path: RouteConstants.editProfile,
            builder: (context, state) => const EditProfileScreen()),
        GoRoute(
          path: '${RouteConstants.movieDetails}/:id',
          name: RouteConstants.movieDetails,
          builder: (context, state) {
            final movieBox = Boxes.getMovies();
            final movieId = state.pathParameters['id']!;
            final movie =
                movieBox.values.firstWhere((movie) => movie.id == movieId);

            return MovieDetailsScreen(movie: movie);
          },
        ),
      ];

  static String? _redirectLogic(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final sb = container.read(signInProvider.notifier);

    final String location = state.matchedLocation;
    debugPrint(location);

    if (sb.isSignedIn) {
      if (location == RouteConstants.login ||
          location == RouteConstants.signup ||
          location == RouteConstants.forgotPassword) {
        return RouteConstants.main;
      }
    }

    return null;
  }
}
