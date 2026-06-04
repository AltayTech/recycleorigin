import 'sizes.dart';

class FeaturedImage {
  final int id;
  final String title;
  final Sizes sizes;

  FeaturedImage({this.id = 0, this.title = '', required this.sizes});

  factory FeaturedImage.fromJson(Map<String, dynamic> parsedJson) {
    final rawSizes = parsedJson['sizes'];
    final sizes =
        rawSizes is Map<String, dynamic> ? Sizes.fromJson(rawSizes) : Sizes();
    return FeaturedImage(
      id: parsedJson['id'] is int
          ? parsedJson['id'] as int
          : int.tryParse('${parsedJson['id']}') ?? 0,
      title: parsedJson['title'] as String? ?? '',
      sizes: sizes,
    );
  }
}
