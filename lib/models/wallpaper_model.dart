class WallpaperModel {
  final int id;
  final String photographer;
  final String url;
  final String small;
  final String medium;
  final String large;
  final String original;

  WallpaperModel({
    required this.id,
    required this.photographer,
    required this.url,
    required this.small,
    required this.medium,
    required this.large,
    required this.original,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>;
    return WallpaperModel(
      id: json['id'] as int,
      photographer: json['photographer'] ?? '',
      url: json['url'] ?? '',
      small: src['small'] ?? '',
      medium: src['medium'] ?? '',
      large: src['large'] ?? '',
      original: src['original'] ?? '',
    );
  }
}
