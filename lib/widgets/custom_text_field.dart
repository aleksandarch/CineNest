import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final void Function(String) onSubmit;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool toObscure;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.onSubmit,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    required this.controller,
    required this.title,
    this.toObscure = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(widget.title)),
          TextFormField(
            controller: widget.controller,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: widget.onSubmit,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            autocorrect: !widget.toObscure,
            textInputAction: widget.textInputAction,
            obscureText: widget.toObscure && isObscured,
            obscuringCharacter: '*',
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: Colors.white,
              suffixIcon: widget.toObscure
                  ? IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(
                          isObscured
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          size: 18),
                      onPressed: () => setState(() => isObscured = !isObscured))
                  : null,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.withValues(alpha: 0.4))),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.withValues(alpha: 0.4))),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.red.shade700)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.deepPurple)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}
