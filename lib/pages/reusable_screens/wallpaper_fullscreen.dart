import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:walliq/models/wallpaper_model.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';


class WallpaperFullscreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  const WallpaperFullscreen({super.key, required this.wallpaper});

  @override
  State<WallpaperFullscreen> createState() => _WallpaperFullscreenState();
}

class _WallpaperFullscreenState extends State<WallpaperFullscreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  double? _displayWidth;
  late double _screenHeight;
  late double _devicePixelRatio;

  @override
  void initState() {
    super.initState();
    _devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    _getImageInfoAndComputeSize();
  }

  Future<void> _getImageInfoAndComputeSize() async {
    final img = NetworkImage(widget.wallpaper.large);
    final completer = Completer<ImageInfo>();
    final stream = img.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info);
    }, onError: (err, st) {
      if (!completer.isCompleted) completer.completeError(err, st);
    });

    stream.addListener(listener);
    try {
      final info = await completer.future;
      // compute width such that image height == screen height (fit height)
      final naturalW = info.image.width.toDouble();
      final naturalH = info.image.height.toDouble();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mq = MediaQuery.of(context);
        setState(() {
          _screenHeight = mq.size.height;
          _devicePixelRatio = mq.devicePixelRatio;
          final aspect = naturalW / naturalH;
          _displayWidth = _screenHeight * aspect; // width shown at fit-to-height
        });
      });
    } catch (e) {
      // fallback: just use full screen width (no overflow)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mq = MediaQuery.of(context);
        setState(() {
          _screenHeight = mq.size.height;
          _devicePixelRatio = mq.devicePixelRatio;
          _displayWidth = mq.size.width;
        });
      });
    } finally {
      stream.removeListener(listener);
    }
  }

  /// Capture the *visible* area inside the RepaintBoundary
  Future<Uint8List?> _captureVisibleImageBytes() async {
    try {
      final boundary =
      _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // Use devicePixelRatio for good resolution
      final ui.Image image =
      await boundary.toImage(pixelRatio: _devicePixelRatio);
      final ByteData? byteData =
      (await image.toByteData(format: ui.ImageByteFormat.png));
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('capture error: $e');
      return null;
    }
  }

  Future<File> _writeBytesToTempFile(Uint8List bytes, {String name = 'wallpaper.png'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes as List<int>);
    return file;
  }

  Future<void> _setWallpaperFromBytes(Uint8List bytes, WallpaperLocation location) async {
    final file = await _writeBytesToTempFile(bytes, name: 'wallpaper_for_setting.png');

    final wallpaperManager = WallpaperManagerFlutter();
    bool result = false;
    try {
      switch (location) {
        case WallpaperLocation.home:
          result = await wallpaperManager.setWallpaper(file, WallpaperManagerFlutter.homeScreen);
          break;
        case WallpaperLocation.lock:
          result = await wallpaperManager.setWallpaper(file, WallpaperManagerFlutter.lockScreen);
          break;
        case WallpaperLocation.both:
          result = await wallpaperManager.setWallpaper(file, WallpaperManagerFlutter.bothScreens);
          break;
      }
    } catch (e) {
      debugPrint('set wallpaper error: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result ? 'Wallpaper set successfully' : 'Could not set wallpaper'),
    ));
  }

  Future<void> _onSetWallpaperPressed() async {
    // show bottom sheet with options
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home Screen'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final bytes = await _captureVisibleImageBytes();
                if (bytes != null) {
                  await _setWallpaperFromBytes(bytes, WallpaperLocation.home);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Lock Screen'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final bytes = await _captureVisibleImageBytes();
                if (bytes != null) {
                  await _setWallpaperFromBytes(bytes, WallpaperLocation.lock);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Home & Lock Screen'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final bytes = await _captureVisibleImageBytes();
                if (bytes != null) {
                  await _setWallpaperFromBytes(bytes, WallpaperLocation.both);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Set with (system wallpaper UI)'),
              subtitle: const Text('Open system wallpaper picker to crop & set'),
              onTap: () async {
                Navigator.of(ctx).pop();
                // open default wallpaper settings (ACTION_SET_WALLPAPER)
                final AndroidIntent intent =
                AndroidIntent(action: 'android.intent.action.SET_WALLPAPER');
                await intent.launch();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDownloadPressed() async {
    // Download original image (so user gets full resolution). Save via gallery_saver_plus / MediaStore.
    try {
      // download to temp file
      final response = await http.get(Uri.parse(widget.wallpaper.large));
      if (response.statusCode != 200) {
        throw Exception('Network error: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      final tmp = await _writeBytesToTempFile(bytes, name: 'download_wallpaper_${widget.wallpaper.id}.jpg');

      // Save to gallery (public Pictures) - gallery_saver_plus will use MediaStore on modern Android
      final res = await GallerySaver.saveImage(tmp.path, albumName: 'Pictures');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res == true ? 'Saved to Pictures' : 'Save failed')),
      );
    } catch (e) {
      debugPrint('download error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> _onFavoritePressed() async {
    // simple Hive usage: store wallpaper URL in box 'favorites' as a Set-like list
    final box = Hive.box('favorites');
    final url = widget.wallpaper.large;
    List favs = box.get('urls', defaultValue: <String>[]);
    if (!favs.contains(url)) {
      favs.add(url);
      await box.put('urls', favs);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already in favorites')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _devicePixelRatio = mq.devicePixelRatio;
    final screenWidth = mq.size.width;
    _screenHeight = mq.size.height;

    // if _displayWidth is null, show a loader while measuring
    final displayWidth = _displayWidth ?? screenWidth;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RepaintBoundary(
          key: _repaintKey,
          child: SizedBox(
            height: _screenHeight,
            width: screenWidth,
            child: Stack(
              children: [
                // horizontal scroll if image width > screen width
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: displayWidth,
                    height: _screenHeight,
                    child: Hero(
                      tag: 'wallpaper_${widget.wallpaper.id}',
                      child: Image.network(
                        widget.wallpaper.large,
                        fit: BoxFit.cover,
                        width: displayWidth,
                        height: _screenHeight,
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (ctx, err, st) {
                          return const Center(child: Icon(Icons.broken_image, size: 64));
                        },
                      ),
                    ),
                  ),
                ),

                // top-left back button
                Positioned(
                  top: 12,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // bottom row: extended set button + two circular buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: FloatingActionButton.extended(
                  onPressed: _onSetWallpaperPressed,
                  label: const Text('Set wallpaper'),
                  icon: const Icon(Icons.wallpaper),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'download_${widget.wallpaper.id}',
                    mini: true,
                    onPressed: _onDownloadPressed,
                    child: const Icon(Icons.download),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'fav_${widget.wallpaper.id}',
                    mini: true,
                    onPressed: _onFavoritePressed,
                    child: const Icon(Icons.favorite_border),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum WallpaperLocation { home, lock, both }

