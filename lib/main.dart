import 'package:cine_nest/firebase_options.dart';
import 'package:cine_nest/routes/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/src/change_notifier_provider.dart';
import 'package:provider/src/provider.dart';

import 'blocs/sign_in_bloc.dart';
import 'boxes/boxes.dart';
import 'models/movie_model.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();

  Hive.registerAdapter(MovieModelAdapter()); // 0

  await Boxes.openMovieBox();

  await Hive.openBox('UserData');

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
        ChangeNotifierProvider<SignInBloc>(create: (context) => SignInBloc()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router,
        scrollBehavior: MyBehavior(),
        title: 'CineNest',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Nexa',
        ),
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
