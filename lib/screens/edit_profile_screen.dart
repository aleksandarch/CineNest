import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/sign_in_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignInBloc>();
    final uid = bloc.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'New Nickname'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final newNickname = _nicknameController.text.trim();
                if (newNickname.isNotEmpty) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
