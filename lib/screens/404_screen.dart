import 'package:cine_nest/constants/constants.dart';
import 'package:cine_nest/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/router_constants.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 1400;
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(40),
          alignment: Alignment.center,
          child: isLargeScreen
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      _buildInfoColumn(context),
                      Flexible(child: const SizedBox(width: 100)),
                      Image.asset('${AppConstants.assetImagePath}cactus.png')
                    ])
              : Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 40,
                  runSpacing: 40,
                  children: [
                    _buildInfoColumn(context),
                    Image.asset('${AppConstants.assetImagePath}cactus.png')
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('404',
            style: TextStyle(
                fontSize: 68,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Too far from the Nest!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('You seem lost...\nLet\'s fly back to CineNest!',
            style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 18)),
        const SizedBox(height: 30),
        CustomButton(
            onPressed: () async => context.go(RouteConstants.main),
            title: 'Back to CineNest'),
      ],
    );
  }
}
