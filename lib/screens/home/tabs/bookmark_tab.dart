import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../blocs/sign_in_bloc.dart'; // Make sure you have the bloc
import '../../../services/bookmark_service.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SignInBloc>();

    if (!bloc.isSignedIn) {
      return const Center(
        child: Text('Please sign in to see your bookmarks.'),
      );
    }

    return StreamBuilder<List<String>>(
      stream: BookmarkService.getBookmarks(bloc.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return const Center(child: Text('No bookmarks yet.'));
        }

        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final movieId = bookmarks[index];
            return ListTile(
              title: Text('Movie ID: $movieId'),
            );
          },
        );
      },
    );
  }
}
