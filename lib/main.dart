import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/bottom_navigation.dart';
import 'package:walliq/providers/wallpaper_provider.dart';
import 'package:walliq/services/pexel_api.dart';

void main() {
  const pexelsKey = '';
  runApp(const MyApp(pexelsKey: pexelsKey));
}

class MyApp extends StatelessWidget {
  final String pexelsKey;
  const MyApp({super.key, required this.pexelsKey});

  @override
  Widget build(BuildContext context) {
    final api = PexelsApi(apiKey: pexelsKey);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WallpaperProvider(api: api)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const BottomNavigation(),
      ),
    );
  }
}
