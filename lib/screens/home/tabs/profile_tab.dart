import 'package:cine_nest/models/movie_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../blocs/bookmark_bloc.dart';
import '../../../blocs/sign_in_bloc.dart';
import '../../../boxes/boxes.dart';
import '../../../routes/router_constants.dart';
import '../../../widgets/empty_page.dart';
import '../../../widgets/movie_display_cards/standard_movie_card.dart';
import '../../../widgets/profile_image_widget.dart';

enum ProfileMenuAction {
  login,
  editProfile,
  logout,
  reloadMovies,
}

extension ProfileMenuActionExtension on ProfileMenuAction {
  String get value {
    switch (this) {
      case ProfileMenuAction.login:
        return 'login';
      case ProfileMenuAction.editProfile:
        return 'editProfile';
      case ProfileMenuAction.logout:
        return 'logout';
      case ProfileMenuAction.reloadMovies:
        return 'reloadMovies';
    }
  }
}

class ProfileScreen extends StatelessWidget {
  final ScrollController scrollController;

  const ProfileScreen({super.key, required this.scrollController});

  void _handleMenuAction(
      BuildContext context, SignInBloc sb, ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.login:
        context.push(RouteConstants.login);
        break;
      case ProfileMenuAction.editProfile:
        context.push(RouteConstants.editProfile);
        break;
      case ProfileMenuAction.logout:
        sb.signOut().then((_) {
          if (context.mounted) context.go(RouteConstants.splash);
        });
        break;
      case ProfileMenuAction.reloadMovies:
        Boxes.getMovies().clear().then((_) {
          if (context.mounted) context.go(RouteConstants.splash);
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveHorizontalPadding = MediaQuery.of(context).padding.left + 20;
    final sb = context.watch<SignInBloc>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: saveHorizontalPadding),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 10),
                child: const Text('Profile',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
            sb.isSignedIn
                ? _buildProfileTabContent(context, sb)
                : const EmptyPage(
                    title: 'Please sign in to see your bookmarks.',
                    showLoginButton: true,
                    artificialExpand: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTabContent(BuildContext context, SignInBloc sb) {
    final bb = context.watch<BookmarkBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileCard(context, sb),
        _buildMyBookmarks(context, bb),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, SignInBloc sb) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.editProfile),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withValues(alpha: 0.2),
                Colors.deepPurple.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.deepPurple.shade200),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImageWidget(imageUrl: sb.profileImageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sb.username ?? 'Nickname not set',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (sb.userEmail != null)
                      Text(sb.userEmail!,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _buildProfileMenu(context, sb),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, SignInBloc sb) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Theme(
        data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: PopupMenuButton<ProfileMenuAction>(
          padding: EdgeInsets.zero,
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.deepPurple.shade200)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.deepPurple),
          onSelected: (action) => _handleMenuAction(context, sb, action),
          itemBuilder: (context) => [
            if (sb.isSignedIn) ...[
              _buildPopupMenuItem(
                  value: ProfileMenuAction.editProfile,
                  icon: CupertinoIcons.pen,
                  iconSize: 20,
                  text: 'Edit Profile'),
              _buildPopupMenuItem(
                  value: ProfileMenuAction.logout,
                  icon: CupertinoIcons.square_arrow_right,
                  text: 'Logout'),
            ] else
              _buildPopupMenuItem(
                  value: ProfileMenuAction.login,
                  icon: CupertinoIcons.square_arrow_right,
                  text: 'Login'),
            PopupMenuItem(
                enabled: false,
                height: 0,
                child: Divider(color: Colors.deepPurple.shade200)),
            _buildPopupMenuItem(
                value: ProfileMenuAction.reloadMovies,
                icon: CupertinoIcons.refresh,
                text: 'Reload Movies'),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ProfileMenuAction> _buildPopupMenuItem({
    required ProfileMenuAction value,
    required IconData icon,
    double iconSize = 18,
    required String text,
    Color iconColor = Colors.deepPurple,
  }) {
    return PopupMenuItem<ProfileMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: 30 - iconSize),
          Text(text)
        ],
      ),
    );
  }

  Widget _buildMyBookmarks(BuildContext context, BookmarkBloc bb) {
    final movieBox = Boxes.getMovies();

    // 1. Create a Map for fast lookup: movieId -> Bookmark
    final bookmarkMap = {
      for (final bookmark in bb.bookmarks) bookmark.movieId: bookmark
    };

    // 2. Filter only movies that are bookmarked
    final movies = movieBox.values
        .where((movie) => bookmarkMap.containsKey(movie.id))
        .toList();

    // 3. Sort the movies based on bookmark.createdOn descending
    movies.sort((a, b) {
      final dateA = bookmarkMap[a.id]?.createdOn ?? DateTime(2025);
      final dateB = bookmarkMap[b.id]?.createdOn ?? DateTime(2025);
      return dateB.compareTo(dateA); // Newest first
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('My Bookmarks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildBookmarksGrid(context, movies),
      ],
    );
  }

  Widget _buildBookmarksGrid(BuildContext context, List<MovieModel> movies) {
    if (movies.isEmpty) {
      return const Padding(
          padding: EdgeInsets.only(top: 80),
          child: EmptyPage(title: 'You have no bookmarks yet.'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3 / 1,
          crossAxisCount: (MediaQuery.of(context).size.width / 500).ceil(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 25),
      itemCount: movies.length,
      itemBuilder: (context, index) => StandardMovieCard(movie: movies[index]),
    );
  }
}
