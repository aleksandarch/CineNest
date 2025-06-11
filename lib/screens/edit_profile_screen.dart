import 'dart:io';

import 'package:cine_nest/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../blocs/sign_in_bloc.dart';
import '../routes/router_constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/profile_image.dart';
import '../widgets/widgets_for_large_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  File? selectedImage;

  @override
  void initState() {
    final sb = context.read<SignInBloc>();
    _nicknameController = TextEditingController(text: sb.username ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final sb = context.read<SignInBloc>();
    if (!sb.isSignedIn) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.go(RouteConstants.login));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.read<SignInBloc>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: WidgetsForLargeScreen(
        formKey: _formKey,
        children: [
          _buildProfileFields(context, sb),
          _buildButtons(context, sb),
        ],
      ),
    );
  }

  Widget _buildProfileFields(BuildContext context, SignInBloc sb) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 10),
      ProfileImage(
          imageUrl: sb.profileImageUrl,
          height: 120,
          enableImageSelect: true,
          onImageSelected: (image) => setState(() => selectedImage = image)),
      const SizedBox(height: 20),
      CustomTextField(
        controller: _nicknameController,
        title: 'Nickname',
        hintText: 'Enter your new nickname',
        onSubmit: (String? value) {},
        validator: Validators.validateNickname,
      ),
    ]);
  }

  Widget _buildButtons(BuildContext context, SignInBloc sb) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                // Check internet connection (optional, you can skip this for now)
                await updateUser(sb);
              }
            },
            title: 'Update Profile'),
        CustomButton(
            onPressed: () async {
              final confirm = await _showPasswordInputDialog(context);
              if (confirm != null && confirm.isNotEmpty && context.mounted) {
                final isSuccessful = await sb.deleteAccount(context, confirm);
                if (context.mounted) {
                  if (isSuccessful) {
                    context.go(RouteConstants.splash);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Failed to delete account. Wrong password?')));
                  }
                }
              }
            },
            title: 'Delete Account',
            inverseColors: true,
            bgColor: Colors.red.shade700),
        CustomButton(
            onPressed: () async {
              final confirm = await _showConfirmationDialog(
                context,
                'Change Password',
                'Are you sure you want to send a password reset email?',
              );
              if (confirm) {
                final isSuccessful =
                    await sb.sendPasswordResetEmail(sb.userEmail!);
                if (context.mounted) {
                  if (isSuccessful) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Password reset email has been sent.')));
                    context.pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Failed to send reset email. Please try again.')));
                  }
                }
              }
            },
            title: 'Change Password',
            inverseColors: true),
        CustomButton(
            onPressed: () async {
              final confirm = await _showConfirmationDialog(
                  context, 'Log Out', 'Are you sure you want to log out?');

              if (confirm && context.mounted) {
                await sb.signOut(context);
              }
            },
            title: 'Log Out',
            inverseColors: true),
      ],
    );
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String message) async {
    return await showDialog<bool>(
          barrierColor: Colors.deepPurple.withValues(alpha: 0.7),
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                  child: Text('Confirm'),
                  onPressed: () => Navigator.of(context).pop(true)),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _showPasswordInputDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void validateAndSubmit() {
      if (formKey.currentState?.validate() ?? false) {
        Navigator.of(context).pop(passwordController.text);
      } else {
        FocusScope.of(context).unfocus();
      }
    }

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: CustomTextField(
                    hintText: 'Enter Your Password',
                    onSubmit: (_) => validateAndSubmit(),
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: Validators.validatePassword,
                    title: 'Password',
                    toObscure: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: validateAndSubmit, // Confirm
              child:
                  Text('Submit', style: TextStyle(color: Colors.red.shade700)),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUser(SignInBloc sb) async {
    final newNickname = _nicknameController.text.trim();
    bool changed = false;

    try {
      if (sb.username != newNickname) {
        await sb.currentUser?.updateDisplayName(newNickname);
        changed = true;
      }

      if (selectedImage != null) {
        final uploadedImageUrl = await sb.uploadProfileImage(selectedImage!);
        if (uploadedImageUrl != null && uploadedImageUrl.isNotEmpty) {
          await sb.currentUser?.updatePhotoURL(uploadedImageUrl);
          changed = true;
        }
      }

      if (changed) await sb.refreshUser();
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to update user: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Failed to update profile')));
      }
    }
  }
}
