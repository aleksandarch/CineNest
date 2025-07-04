import 'package:cine_nest/widgets/app_logo_widget.dart';
import 'package:cine_nest/widgets/custom_button.dart';
import 'package:cine_nest/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sign_in_provider.dart';
import '../../routes/router_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/text_link_button.dart';
import '../../widgets/widgets_for_large_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    bool validateForm() {
      if (_formKey.currentState == null) return false;
      return _formKey.currentState!.validate();
    }

    if (!validateForm()) return;

    setState(() => _isLoading = true);
    final sb = ref.read(signInProvider.notifier);

    final user = await sb.signInWithEmail(
        _emailController.text.trim(), _passwordController.text.trim());

    if (context.mounted) {
      _handleLoginResult(context, user, 'Invalid email or password.');
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    final sb = ref.read(signInProvider.notifier);
    final user = await sb.signInWithGoogle();

    if (context.mounted) {
      _handleLoginResult(context, user, 'Google sign-in canceled.');
    }
  }

  void _handleLoginResult(
      BuildContext context, User? user, String errorMessage) {
    if (user != null) {
      context.replace(RouteConstants.main);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Login')),
      body: WidgetsForLargeScreen(
        formKey: _formKey,
        children: [
          AppLogoWidget(),
          _buildTextField(),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      children: [
        CustomTextField(
            hintText: 'Enter Your Email Address',
            onSubmit: (_) {},
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
            title: 'Email'),
        const SizedBox(height: 14),
        CustomTextField(
            hintText: 'Enter Your Password',
            onSubmit: (_) {},
            controller: _passwordController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            title: 'Password',
            toObscure: true),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        CustomButton(
            onPressed: () async {
              if (!_isLoading) await _login(context);
            },
            title: 'Login'),
        const SizedBox(height: 4),
        CustomButton(
            onPressed: () async {
              if (!_isLoading) await _loginWithGoogle(context);
            },
            title: 'Sign in with Google',
            inverseColors: true),
        const SizedBox(height: 26),
        Column(
          children: [
            TextLinkButton(
                leadingText: 'Don’t have an account?',
                trailingText: 'Sign Up',
                onTap: () => context.push(RouteConstants.signup),
                isDisabled: _isLoading),
            const SizedBox(height: 14),
            TextLinkButton(
                leadingText: 'Forgot Password?',
                trailingText: 'Reset it',
                onTap: () => context.push(RouteConstants.forgotPassword),
                isDisabled: _isLoading),
          ],
        ),
      ],
    );
  }
}
