import 'package:cine_nest/constants/constants.dart';
import 'package:cine_nest/firebase_options.dart';
import 'package:cine_nest/routes/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'blocs/bookmark_bloc.dart';
import 'blocs/sign_in_bloc.dart';
import 'boxes/boxes.dart';
import 'models/bookmark_model.dart';
import 'models/movie_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();

  Hive.registerAdapter(MovieModelAdapter()); // 0
  Hive.registerAdapter(BookmarkModelAdapter()); // 1

  await Boxes.openMovieBox();
  await Boxes.openUserDataBox();
  await Boxes.openBookmarkBox();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(const CineNestApp());
}

class CineNestApp extends StatelessWidget {
  const CineNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkBloc()),
        ChangeNotifierProvider<SignInBloc>(create: (context) => SignInBloc()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router,
        scrollBehavior: MyBehavior(),
        title: 'CineNest',
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            fontFamily: AppConstants.fontsFamily),
      ),
    );
  }
}

// Removes Android scroll glow
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
