import 'package:flutter/material.dart';
import 'package:pebbles/app_screens/collection.dart';
import 'package:pebbles/app_screens/home.dart';
import 'package:pebbles/app_screens/settings.dart';
import 'package:pebbles/app_screens/create_pebble.dart';
import 'package:pebbles/app_screens/news.dart';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class RockNavigator extends StatefulWidget {
  const RockNavigator({super.key});

  @override
  State<StatefulWidget> createState() {
    return RockNavigatorState();
  }
}

class RockNavigatorState extends State<RockNavigator> {
  int _currentIndex = 2;

  // List of pages to display
  final List<Widget> _pages = [
    const News(),
    const CreatePebble(),
    const Home(),
    const Collection(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.lightGreen,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.newspaper, title: 'News'),
          TabItem(icon: Icons.create, title: 'Create'),
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.collections, title: 'Collection'),
          TabItem(icon: Icons.settings, title: 'Settings'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}
