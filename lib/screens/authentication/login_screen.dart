import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../blocs/bookmark_bloc.dart';
import '../../blocs/sign_in_bloc.dart';
import '../../routes/router_constants.dart';
import '../../services/bookmark_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final bloc = context.read<SignInBloc>();
      final user = await bloc.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        final bookmarkNotifier =
            Provider.of<BookmarkBloc>(context, listen: false);
        BookmarkService.subscribeToBookmarks(user?.uid ?? '', bookmarkNotifier);
        context.go(RouteConstants.main);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final bloc = context.read<SignInBloc>();
      await bloc.signInWithGoogle();
      if (mounted) {
        context.go(RouteConstants.main);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('here');
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _login(context),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _loginWithGoogle(context),
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Google'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(RouteConstants.signup);
                        },
                        child: const Text('Don’t have an account? Sign Up'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(RouteConstants.forgotPassword);
                        },
                        child: const Text('Forgot Password? Reset it'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
