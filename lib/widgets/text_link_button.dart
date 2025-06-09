import 'package:flutter/material.dart';

class TextLinkButton extends StatelessWidget {
  final String leadingText;
  final String trailingText;
  final VoidCallback onTap;
  final bool isDisabled;

  const TextLinkButton({
    super.key,
    required this.leadingText,
    required this.trailingText,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            leadingText,
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            trailingText,
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.deepPurple,
              decorationColor: Colors.deepPurple,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
