import 'package:flutter/material.dart';

import 'loader.dart';

class CustomButton extends StatefulWidget {
  final String title;
  final Future<void> Function() onPressed;
  final bool inverseColors;
  final Color bgColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.inverseColors = false,
    this.bgColor = Colors.deepPurple,
    this.textColor = Colors.white,
    required this.title,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 0.95,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    await widget.onPressed();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handlePress,
      onTapDown: (_) => _animationController.reverse(), // scale down
      onTapUp: (_) => _animationController.forward(), // scale up
      onTapCancel: () => _animationController.forward(), // scale up
      child: ScaleTransition(
        scale: _animationController,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          height: 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          decoration: BoxDecoration(
            color: widget.inverseColors ? widget.textColor : widget.bgColor,
            border: Border.all(
              color: widget.inverseColors ? widget.bgColor : widget.textColor,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _isLoading
                ? Loader(
                    key: ValueKey('loader'),
                    color: widget.inverseColors
                        ? widget.bgColor
                        : widget.textColor,
                    loaderWidth: 20)
                : Text(widget.title,
                    key: ValueKey('text'),
                    style: TextStyle(
                        color: widget.inverseColors
                            ? widget.bgColor
                            : widget.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
