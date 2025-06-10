import 'package:cine_nest/widgets/app_logo_widget.dart';
import 'package:cine_nest/widgets/custom_button.dart';
import 'package:cine_nest/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../blocs/sign_in_bloc.dart';
import '../../routes/router_constants.dart';
import '../../utils/validators.dart';
import '../../widgets/text_link_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final sb = context.read<SignInBloc>();

    final user = await sb.signInWithEmail(
        _emailController.text.trim(), _passwordController.text.trim());

    if (context.mounted) {
      _handleLoginResult(context, user, 'Invalid email or password.');
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    final bloc = context.read<SignInBloc>();
    final user = await bloc.signInWithGoogle();

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
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AppLogoWidget(),
                        _buildTextField(),
                        _buildButtons(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Form(
      key: _formKey,
      child: Column(
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
      ),
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
        if (!kIsWeb)
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
