import 'package:cine_nest/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/sign_in_bloc.dart';
import '../widgets/profile_image_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nicknameController;

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
  Widget build(BuildContext context) {
    final saveHorizontalPadding = MediaQuery.of(context).padding.left + 20;
    final sb = context.read<SignInBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProfileFields(context, sb),
                        _buildButtons(context, sb),
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

  Widget _buildProfileFields(BuildContext context, SignInBloc sb) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 10),
      ProfileImageWidget(imageUrl: sb.profileImageUrl, height: 120),
      const SizedBox(height: 20),
      TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(labelText: 'New Nickname')),
    ]);
  }

  Widget _buildButtons(BuildContext context, SignInBloc sb) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
            onPressed: () async {
              await Future.delayed(Duration(seconds: 4), () {});
            },
            title: 'Update Profile'),
        CustomButton(
          onPressed: () async {},
          title: 'Delete Account',
          inverseColors: true,
          bgColor: Colors.red.shade700,
        ),
        CustomButton(
          onPressed: () async {},
          title: 'Change Password',
          inverseColors: true,
        ),
        CustomButton(
            onPressed: () async {}, title: 'Log Out', inverseColors: true),
      ],
    );
  }
}
