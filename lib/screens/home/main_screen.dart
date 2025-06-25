import 'package:cine_nest/screens/home/tabs/home_tab.dart';
import 'package:cine_nest/screens/home/tabs/profile_tab.dart';
import 'package:cine_nest/screens/home/tabs/search_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookmark_provider.dart';
import '../../providers/sign_in_provider.dart';
import '../../widgets/animated_bottom_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final sb = ref.read(signInProvider.notifier);
    if (sb.isSignedIn) {
      ref.read(bookmarkProvider.notifier).startSync(sb.userId!);
    }

    tabController =
        TabController(vsync: this, length: 3, initialIndex: _currentIndex);
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        bottomNavigationBar: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBottomBar(
                scrollController: scrollController,
                currentIndex: _currentIndex,
                onTabSelected: _onTabSelected)),
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeScreen(scrollController: scrollController),
              SearchTab(scrollController: scrollController),
              ProfileScreen(scrollController: scrollController),
            ],
          ),
        ));
  }
}
