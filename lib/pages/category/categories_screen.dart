import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_list_screen.dart';
import 'package:walliq/providers/wallpaper_provider.dart';
import 'dart:ui';

class Categories extends StatelessWidget {
  Categories({super.key});

  final Map<String, String> categoryImages = {
    "Nature":
        "https://images.pexels.com/photos/355241/pexels-photo-355241.jpeg",
    "Animals":
        "https://images.pexels.com/photos/145939/pexels-photo-145939.jpeg",
    "Cars": "https://images.pexels.com/photos/210019/pexels-photo-210019.jpeg",
    "Architecture":
        "https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg",
    "Technology":
        "https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg",
    "Abstract":
        "https://images.pexels.com/photos/1738986/pexels-photo-1738986.jpeg",
    "Travel":
        "https://images.pexels.com/photos/346885/pexels-photo-346885.jpeg",
    "Food": "https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg",
    "Sports":
        "https://images.pexels.com/photos/47730/the-ball-stadion-football-the-pitch-47730.jpeg",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "C A T E G O R I E S",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 8,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.9,
        ),
        itemCount: categoryImages.length,
        itemBuilder: (context, index) {
          final category = categoryImages.keys.elementAt(index);
          final imageUrl = categoryImages[category]!;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WallpaperListScreen(
                    title: category,
                    fetchFunction: (page) => Provider.of<WallpaperProvider>(
                      context,
                      listen: false,
                    ).fetchCategory(category, refresh: page == 1),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image from URL
                  Image.network(imageUrl, fit: BoxFit.cover),

                  // Blur effect
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: Container(color: Colors.black26),
                  ),

                  // Category text
                  Center(
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
