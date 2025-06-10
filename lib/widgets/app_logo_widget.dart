import 'package:flutter/material.dart';

import '../constants/constants.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 70,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 12, right: 8),
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36))),
            child: Image.asset('${AppConstants.assetImagePath}app_icon.png',
                height: 60)),
        Container(
          height: 70,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(36),
                  bottomRight: Radius.circular(36))),
          child: Text(AppConstants.appName,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
        ),
      ],
    );
  }
}
