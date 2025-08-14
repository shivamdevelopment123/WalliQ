import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_list_screen.dart';
import 'package:walliq/providers/wallpaper_provider.dart';

class Categories extends StatelessWidget {
  Categories({super.key});

  final List<String> categories = [
    "Nature",
    "Animals",
    "Cars",
    "Architecture",
    "Technology",
    "Abstract",
    "Travel",
    "Food",
    "Sports",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WallpaperListScreen(
                    title: category,
                    fetchFunction: (page) =>
                        Provider.of<WallpaperProvider>(context, listen: false)
                            .fetchCategory(category, refresh: page == 1),

                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage("assets/categories/${category.toLowerCase()}.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black45,
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

