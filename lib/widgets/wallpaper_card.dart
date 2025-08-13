import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walliq/models/wallpaper_model.dart';

class WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback? onTap;
  final double borderRadius;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    this.onTap,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: CachedNetworkImage(
            imageUrl: wallpaper.large,
            fit: BoxFit.cover,
            placeholder: (c, s) => Container(
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (c, s, e) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }
}
