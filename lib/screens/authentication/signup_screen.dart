import 'package:cine_nest/widgets/custom_button.dart';
import 'package:cine_nest/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sign_in_provider.dart';
import '../../routes/router_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo_widget.dart';
import '../../widgets/text_link_button.dart';
import '../../widgets/widgets_for_large_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    final sb = ref.read(signInProvider.notifier);
    if (sb.isSignedIn) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go(RouteConstants.main));
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final sb = ref.read(signInProvider.notifier);
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await sb.signUp(nickname, email, password);
    if (mounted) {
      if (user != null) {
        context.replace(RouteConstants.main);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: WidgetsForLargeScreen(
        formKey: _formKey,
        children: [
          AppLogoWidget(),
          _buildTextField(),
          CustomButton(onPressed: _signup, title: 'Sign Up'),
          TextLinkButton(
              leadingText: 'Already have an account?',
              trailingText: 'Log in',
              onTap: () => context.pop()),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      children: [
        CustomTextField(
            hintText: 'Enter Nickname',
            onSubmit: (_) {},
            controller: _nicknameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: Validators.validateNickname,
            title: 'Nickname'),
        const SizedBox(height: 14),
        CustomTextField(
            hintText: 'Enter Email Address',
            onSubmit: (_) {},
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
            title: 'Email'),
        const SizedBox(height: 14),
        CustomTextField(
            hintText: 'Enter Password',
            onSubmit: (_) {},
            controller: _passwordController,
            keyboardType: TextInputType.text,
            toObscure: true,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            title: 'Password'),
      ],
    );
  }
}
