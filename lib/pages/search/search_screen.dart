import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_fullscreen.dart';
import 'package:walliq/providers/wallpaper_provider.dart';
import 'package:walliq/widgets/wallpaper_card.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';
  int _page = 1;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !Provider.of<WallpaperProvider>(context, listen: false).searching &&
          _currentQuery.isNotEmpty) {
        _page++;
        Provider.of<WallpaperProvider>(
          context,
          listen: false,
        ).search(_currentQuery, page: _page);
      }
    });
  }

  void _startSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _currentQuery = query.trim();
      _page = 1;
    });
    Provider.of<WallpaperProvider>(
      context,
      listen: false,
    ).search(_currentQuery, page: _page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search wallpapers...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _startSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _startSearch(_controller.text),
          ),
        ],
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, prov, _) {
          if (_currentQuery.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Start searching for wallpapers',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (prov.searching && prov.searchResults.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.error != null && prov.searchResults.isEmpty) {
            return Center(child: Text('Error: ${prov.error}'));
          }

          if (prov.searchResults.isEmpty) {
            return const Center(child: Text('No wallpapers found.'));
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.66,
            ),
            itemCount: prov.searchResults.length + (prov.searching ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= prov.searchResults.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final wallpaper = prov.searchResults[i];
              return WallpaperCard(
                wallpaper: wallpaper,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WallpaperFullscreen(wallpaper: wallpaper),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
