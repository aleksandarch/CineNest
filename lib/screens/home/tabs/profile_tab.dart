import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../blocs/sign_in_bloc.dart';
import '../../../routes/router_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final bloc = context.read<SignInBloc>();
    await bloc.signOut();
    // await Boxes.clear(); // Clear local Hive boxes
  }

  Future<void> _deleteAccount(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SignInBloc>();

    if (!bloc.isSignedIn) {
      return const Center(child: Text('Please log in.'));
    }

    final user = bloc.currentUser!;
    final nickname = 'Aleks';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.email ?? 'No Email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              nickname,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push(RouteConstants.editProfile);
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => _deleteAccount(context),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
