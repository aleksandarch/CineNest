import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/sign_in_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendResetEmail(BuildContext context) async {
    final bloc = context.read<SignInBloc>();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    await bloc.sendPasswordResetEmail(email);
    if (bloc.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bloc.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
      if (mounted) {
        Navigator.of(context).pop(); // Go back to login screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SignInBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 24),
            bloc.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _sendResetEmail(context),
                    child: const Text('Send Reset Email'),
                  ),
          ],
        ),
      ),
    );
  }
}
