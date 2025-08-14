import 'package:flutter/material.dart';
import 'package:walliq/models/wallpaper_model.dart';

class WallpaperFullscreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  const WallpaperFullscreen({super.key, required this.wallpaper});

  @override
  State<WallpaperFullscreen> createState() => _WallpaperFullscreenState();
}

class _WallpaperFullscreenState extends State<WallpaperFullscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Hero(tag:'wallpaper_${widget.wallpaper.id}',
                child: Image.network(
                  widget.wallpaper.large,
                  fit: BoxFit.cover,
                ),
            ),
          ),
        ],
      ),
    );
  }
}
