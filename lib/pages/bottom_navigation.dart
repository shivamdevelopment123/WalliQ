import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:walliq/pages/home/home_screen.dart';
import 'package:walliq/pages/search/search_screen.dart';
import 'category/categories_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late List<Widget> pages;
  late Home home;
  late Categories categories;
  late Search search;
  late Widget currentPage;

  @override
  void initState() {
    home = Home();
    categories = Categories();
    search = Search();
    pages = [home, search, categories];
    currentPage = Home();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Theme.of(context).colorScheme.inverseSurface,
          height: 50,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (int index) {
            setState(() {
              currentPage = pages[index];
            });
          },
          items: [
            Icon(Icons.home_outlined),
            Icon(Icons.search_outlined),
            Icon(Icons.category_outlined),
          ],
        ),
        body: currentPage,
      ),
    );
  }
}
