import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/router_constants.dart';
import '../services/movie_service.dart';
import 'custom_button.dart';

class EmptyPage extends StatelessWidget {
  final String title;
  final bool showReloadButton;
  final bool showLoginButton;
  final bool artificialExpand;

  const EmptyPage({
    super.key,
    required this.title,
    this.showReloadButton = false,
    this.showLoginButton = false,
    this.artificialExpand = false,
  });

  Future<void> _reloadMovies() async {
    await MovieService.instance.refreshMovies(toEmptyBox: true);
  }

  void _loginNow(BuildContext context) {
    context.push(RouteConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: artificialExpand
          ? MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              60
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(MediaQuery.of(context).size.height ~/ 300,
                  (index) => _emptyCard(index % 2 == 0)),
              SizedBox(height: 10),
              Text(title,
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.7))),
              if (showReloadButton)
                CustomButton(title: 'Reload Movies', onPressed: _reloadMovies),
              if (showLoginButton)
                CustomButton(
                    title: 'Login Now',
                    onPressed: () async => _loginNow(context)),
            ],
          ),
          const SizedBox()
        ],
      ),
    );
  }

  Widget _emptyCard(bool isMarked) {
    return Container(
        constraints: BoxConstraints(maxWidth: 500),
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withValues(alpha: 0.05),
              Colors.deepPurple.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.1)),
        ),
        height: 80,
        child: Row(
          children: [
            Icon(CupertinoIcons.photo,
                size: 50, color: Colors.deepPurple.withValues(alpha: 0.2)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          height: 10,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Icon(
                          isMarked
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                          color: Colors.white.withValues(alpha: 0.6))
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 10,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
