import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/model_bottom_bar_tab.dart';

class AnimatedBottomBar extends StatelessWidget {
  final ScrollController scrollController;
  final int currentIndex;
  final Function(int) onTabSelected;

  const AnimatedBottomBar({
    super.key,
    required this.scrollController,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const double iconHeight = 20.0;

  static final List<ModelBottomBarTab> myTabs = [
    ModelBottomBarTab(
        selectedIcon: CupertinoIcons.house_fill,
        unselectedIcon: CupertinoIcons.house),
    ModelBottomBarTab(
        selectedIcon: CupertinoIcons.search,
        unselectedIcon: CupertinoIcons.search),
    ModelBottomBarTab(
        selectedIcon: CupertinoIcons.person,
        unselectedIcon: CupertinoIcons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollToHideWidget(
      iconHeight: iconHeight,
      controller: scrollController,
      child: BlurryContainer(
        blur: 12,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(50),
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(myTabs.length, (index) {
            final tab = myTabs[index];
            final isActiveTab = index == currentIndex;
            return GestureDetector(
              onTap: currentIndex == index ? null : () => onTabSelected(index),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                    color: isActiveTab
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    borderRadius: BorderRadius.circular(60)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Icon(isActiveTab ? tab.selectedIcon : tab.unselectedIcon,
                    size: iconHeight,
                    color: isActiveTab
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ScrollToHideWidget extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double iconHeight;

  const ScrollToHideWidget({
    super.key,
    required this.child,
    required this.controller,
    required this.iconHeight,
  });

  @override
  State<ScrollToHideWidget> createState() => _ScrollToHideWidgetState();
}

class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listen);
    super.dispose();
  }

  void listen() {
    final direction = widget.controller.position.userScrollDirection;
    if (direction == ScrollDirection.forward) show();
    if (direction == ScrollDirection.reverse) hide();
    if (WidgetsBinding
            .instance.platformDispatcher.views.first.viewInsets.bottom >
        0.0) {
      hide();
    }
  }

  void show() {
    if (!isVisible) setState(() => isVisible = true);
  }

  void hide() {
    if (isVisible) setState(() => isVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final tabButtonWithPaddingHeight = widget.iconHeight + 32;

    return AnimatedContainer(
        margin: EdgeInsets.only(
            bottom: isVisible ? MediaQuery.of(context).padding.bottom + 10 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        height: isVisible ? tabButtonWithPaddingHeight : 0,
        child: Wrap(children: [widget.child]));
  }
}
