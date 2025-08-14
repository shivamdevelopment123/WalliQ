import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_fullscreen.dart';
import 'package:walliq/pages/reusable_screens/wallpaper_list_screen.dart';
import '../../providers/wallpaper_provider.dart';
import '../../widgets/wallpaper_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<WallpaperProvider>(context, listen: false);
    prov.fetchCurated().then((_) => prov.fetchTopRated());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('WalliQ', style: TextStyle(fontFamily: 'Poppins')),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, prov, _) {
          final curated = prov.curated;
          final topRated = prov.topRated;
          if (prov.loadingCurated && curated.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          if (prov.error != null && curated.isEmpty) {
            return Center(child: Text('Error: ${prov.error}'));
          }
          if (curated.isEmpty) {
            return Center(child: Text('No wallpapers yet'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: curated.length,
                  itemBuilder: (context, index, realIdx) {
                    final w = curated[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Hero(
                        tag: 'wallpaper_${w.id}',
                        child: WallpaperCard(
                          wallpaper: w,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WallpaperFullscreen(wallpaper: w),
                              ),
                            );
                          },
                          borderRadius: 16,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: screenHeight * 0.45,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                  ),
                ),
                SizedBox(height: 16),
                // "Latest" Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full curated list page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WallpaperListScreen(
                                title: 'C U R A T E D',
                                fetchFunction: (page) =>
                                    prov.api.curated(perPage: 14, page: page),
                              ),
                            ),
                          );
                        },
                        child: Text('See all'),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: curated.length,
                  itemBuilder: (context, i) => WallpaperCard(
                    wallpaper: curated[i],
                    onTap: () {
                      // Navigate to detail preview
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WallpaperFullscreen(wallpaper: curated[i]),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
                // "Top Rated" Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full top-rated list
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WallpaperListScreen(
                                title: 'P O P U L A R',
                                fetchFunction: (page) =>
                                    prov.api.popular(perPage: 14),
                              ),
                            ),
                          );
                        },
                        child: Text('See all'),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: topRated.length,
                  itemBuilder: (context, i) => WallpaperCard(
                    wallpaper: topRated[i],
                    onTap: () {
                      // Navigate to detail preview
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WallpaperFullscreen(wallpaper: topRated[i]),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
