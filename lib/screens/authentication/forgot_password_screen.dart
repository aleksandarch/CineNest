import 'package:cine_nest/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sign_in_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/widgets_for_large_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    bool validateForm() {
      if (_formKey.currentState == null) return false;
      return _formKey.currentState!.validate();
    }

    if (_isLoading || !validateForm()) return;
    setState(() => _isLoading = true);

    final sb = ref.read(signInProvider.notifier);
    final email = _emailController.text.trim();

    final isSuccessful = await sb.sendPasswordResetEmail(email);
    if (mounted) {
      if (isSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent!')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error sending the email. Please try again.')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: WidgetsForLargeScreen(
        formKey: _formKey,
        children: [
          CustomTextField(
              hintText: 'Enter Your Email Address',
              onSubmit: (_) => _sendResetEmail(),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.validateEmail,
              title: 'Email'),
          const SizedBox(),
          Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: CustomButton(
                  onPressed: _sendResetEmail, title: 'Send Reset Email')),
        ],
      ),
    );
  }
}
