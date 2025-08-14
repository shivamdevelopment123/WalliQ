

import 'package:flutter/material.dart';
import 'package:walliq/models/wallpaper_model.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_fullscreen.dart';
import 'package:walliq/widgets/wallpaper_card.dart';

class WallpaperListScreen extends StatefulWidget {
  final String title;
  final Future<List<WallpaperModel>> Function(int page) fetchFunction;
  const WallpaperListScreen({
    super.key,
    required this.title,
    required this.fetchFunction,
  });

  @override
  State<WallpaperListScreen> createState() => _WallpaperListScreenState();
}

class _WallpaperListScreenState extends State<WallpaperListScreen> {
  List<WallpaperModel> wallpapers = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasMore) {
        _fetchWallpapers();
      }
    });
  }

  Future<void> _fetchWallpapers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final newWallpapers = await widget.fetchFunction(currentPage);
      if (newWallpapers.isEmpty) {
        setState(() {
          hasMore = false;
        });
      } else {
        setState(() {
          wallpapers.addAll(newWallpapers);
          currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 8,
      ),
      body: wallpapers.isEmpty && isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.66,
              ),
              itemCount: wallpapers.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= wallpapers.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return WallpaperCard(
                  wallpaper: wallpapers[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WallpaperFullscreen(wallpaper: wallpapers[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
