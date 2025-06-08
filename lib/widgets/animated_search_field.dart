import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final List<String> hintTexts;
  final ValueChanged<String> onChanged;

  const AnimatedTextField(
      {super.key, required this.hintTexts, required this.onChanged});

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: (value) {
        FocusScope.of(context).unfocus();
        widget.onChanged(value);
      },
      keyboardType: TextInputType.text,
      autocorrect: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        suffixIcon: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _focusNode.hasFocus
              ? IconButton(
                  key: const ValueKey('clearIcon'),
                  icon: const Icon(CupertinoIcons.clear, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                )
              : const SizedBox(key: ValueKey('emptySpace')),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide:
                BorderSide(color: Colors.deepPurple.withValues(alpha: 0.4))),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide:
                BorderSide(color: Colors.deepPurple.withValues(alpha: 0.4))),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide:
                BorderSide(color: Colors.deepPurple.withValues(alpha: 0.4))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        label: _focusNode.hasFocus || _controller.text.isNotEmpty
            ? null
            : AnimatedTextKit(
                repeatForever: true,
                animatedTexts: widget.hintTexts.map((text) {
                  return TyperAnimatedText(
                    text,
                    speed: Duration(
                        milliseconds: 1000 ~/ (text.isEmpty ? 1 : text.length)),
                    textAlign: TextAlign.start,
                    textStyle: TextStyle(
                        color: Colors.deepPurple.withValues(alpha: 0.6),
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                isRepeatingAnimation: true,
                pause: const Duration(milliseconds: 1000)),
      ),
    );
  }
}
