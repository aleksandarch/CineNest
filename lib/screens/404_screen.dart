import 'package:cine_nest/constants/constants.dart';
import 'package:cine_nest/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/router_constants.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text('🎬🪺', style: TextStyle(fontSize: 64)),
                Text('404\nToo far from the Nest!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('You seem lost...\nLet\'s fly back to CineNest!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.black54)),
                const SizedBox(height: 30),
                CustomButton(
                    onPressed: () async => context.go(RouteConstants.main),
                    title: 'Back to CineNest'),
                Image.asset('${AppConstants.assetImagePath}cactus.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
