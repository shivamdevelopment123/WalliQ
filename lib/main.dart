import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:walliq/pages/bottom_navigation.dart';
import 'package:walliq/providers/wallpaper_provider.dart';
import 'package:walliq/services/pexel_api.dart';
import 'package:walliq/themes/dark_mode.dart';
import 'package:walliq/themes/light_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final pexelsKey = dotenv.env['PEXELS_API_KEY'] ?? '';
  runApp(MyApp(pexelsKey: pexelsKey));
}

class MyApp extends StatelessWidget {
  final String pexelsKey;
  const MyApp({super.key, required this.pexelsKey});

  @override
  Widget build(BuildContext context) {
    final api = PexelsApi(apiKey: pexelsKey);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WallpaperProvider(api: api),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: ThemeMode.system,
        home: const BottomNavigation(),
      ),
    );
  }
}
