import 'package:cine_nest/screens/home/tabs/search_tab.dart';
import 'package:flutter/material.dart';

import '../../widgets/animated_bottom_bar.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
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
