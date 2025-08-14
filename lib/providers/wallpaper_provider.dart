import 'package:flutter/cupertino.dart';
import 'package:walliq/models/wallpaper_model.dart';
import 'package:walliq/services/pexel_api.dart';

class WallpaperProvider extends ChangeNotifier{
  final PexelsApi api;
  WallpaperProvider({required this.api});

  List<WallpaperModel> curated = [];
  bool loadingCurated = false;
  String? error;

  int curatedPage = 1;
  bool hasMoreCurated = true;

  Future<void> fetchCurated({bool refresh = false}) async {
    if(loadingCurated) return;
    loadingCurated = true;
    if(refresh){
      curatedPage = 1;
      curated = [];
      hasMoreCurated = true;
    }
    notifyListeners();
    try{
      final results = await api.curated(perPage: 10, page: curatedPage);
      if(results.isEmpty){
        hasMoreCurated = false;
      }else{
        curated.addAll(results);
        curatedPage++;
      }
      error = null;
    }catch (e){
      error = e.toString();
    } finally {
      loadingCurated = false;
      notifyListeners();
    }
  }

  //searching...
  List<WallpaperModel> searchResults = [];
  bool searching = false;

  Future<void> search(String query,{int page = 1}) async {
    searching = true;
    notifyListeners();
    try{
      final results = await api.search(query, perPage: 30,page: page);
      if(page == 1) {
        searchResults = results;
      } else {
        searchResults.addAll(results);
      }
      error = null;
    }catch (e) {
      error = e.toString();
    } finally {
      searching = false;
      notifyListeners();
    }
  }

  //top rated..
  List<WallpaperModel> topRated = [];
  bool loadingTopRated = false;

  Future<void> fetchTopRated() async {
    loadingTopRated = true;
    notifyListeners();
    try {
      topRated = await api.popular(perPage: 10);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loadingTopRated = false;
      notifyListeners();
    }
  }

  // Category storage
  Map<String, List<WallpaperModel>> categoryResults = {};
  Map<String, bool> loadingCategory = {};
  Map<String, bool> hasMoreCategory = {};
  Map<String, int> categoryPage = {};

// Fetch category wallpapers
  Future<List<WallpaperModel>> fetchCategory(String category, {bool refresh = false, int perPage = 20, int page = 1}) async {
    loadingCategory[category] = true;
    notifyListeners();

    try {
      final results = await api.search(category, perPage: perPage, page: page);

      if (refresh || !categoryResults.containsKey(category)) {
        categoryResults[category] = results;
        categoryPage[category] = 2;
      } else {
        categoryResults[category]!.addAll(results);
        categoryPage[category] = (categoryPage[category] ?? 1) + 1;
      }

      hasMoreCategory[category] = results.isNotEmpty;
      error = null;

      return results; // ✅ Now returns List<WallpaperModel>
    } catch (e) {
      error = e.toString();
      return []; // Return empty list on error
    } finally {
      loadingCategory[category] = false;
      notifyListeners();
    }
  }
}