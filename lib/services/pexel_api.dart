import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:walliq/models/wallpaper_model.dart';

class PexelsApi{
  PexelsApi({required this.apiKey});
  final String apiKey;
  static const String baseUrl = 'https://api.pexels.com/v1';

  Map<String, String> get headers => {
    'Authorization' : apiKey
  };

  Future<List<WallpaperModel>> curated({int perPage = 20, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/curated?per_page=$perPage&page=$page');
    final response = await http.get(uri, headers: headers);

    if(response.statusCode == 200){
      final body = json.decode(response.body);
      final photos = body['photos'] as List<dynamic>;
      return photos.map((p) => WallpaperModel.fromJson(p)).toList();
    }else{
      debugPrint('Pexels curated error: ${response.statusCode}');
      throw Exception('Failed to load curated wallpapers');
    }
  }

  Future<List<WallpaperModel>> search(String query, {int perPage = 20, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/search?query=${Uri.encodeComponent(query)}&per_page=$perPage&page=$page');
    final  response = await http.get(uri, headers: headers);
    if(response.statusCode == 200){
      final body = json.decode(response.body);
      final photos = body['photos'] as List<dynamic>;
      return photos.map((p) => WallpaperModel.fromJson(p)).toList();
    }else{
      debugPrint('Pexels search error: ${response.statusCode}');
      throw Exception('Failed to load search wallpapers');
    }
  }

  Future<List<WallpaperModel>> popular({int perPage = 20, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/popular?per_page=$perPage&page=$page');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final photos = body['photos'] as List<dynamic>;
      return photos.map((p) => WallpaperModel.fromJson(p)).toList();
    } else {
      debugPrint('Pexels popular error: ${response.statusCode}');
      throw Exception('Failed to load top rated wallpapers');
    }
  }

  Future<List<WallpaperModel>> categoryWallpapers(String category, {int perPage = 20, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/search?query=${Uri.encodeComponent(category)}&per_page=$perPage&page=$page');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final photos = body['photos'] as List<dynamic>;
      return photos.map((p) => WallpaperModel.fromJson(p)).toList();
    } else {
      debugPrint('Pexels category error: ${response.statusCode}');
      throw Exception('Failed to load category wallpapers');
    }
  }
}