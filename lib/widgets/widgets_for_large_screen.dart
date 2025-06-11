import 'package:flutter/material.dart';

class WidgetsForLargeScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  const WidgetsForLargeScreen(
      {super.key, required this.formKey, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: LayoutBuilder(builder: (context, constraints) {
          final bool isLargeScreen = MediaQuery.of(context).size.width > 600 &&
              MediaQuery.of(context).size.height > 600;
          return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: isLargeScreen
                    ? BoxConstraints()
                    : BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  padding: isLargeScreen ? const EdgeInsets.all(20) : null,
                  width: isLargeScreen ? 500 : null,
                  height: isLargeScreen ? 600 : null,
                  decoration: isLargeScreen
                      ? BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(26))
                      : null,
                  child: IntrinsicHeight(
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: isLargeScreen
                                ? MainAxisAlignment.spaceAround
                                : MainAxisAlignment.spaceBetween,
                            children: isLargeScreen
                                ? children
                                : ([const SizedBox(), ...children]),
                          ))),
                )),
          );
        }),
      )),
    );
  }
}
