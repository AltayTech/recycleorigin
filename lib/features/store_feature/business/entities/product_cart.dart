import 'package:flutter/foundation.dart';

import 'color_code_card.dart';
import 'brandc.dart';

class ProductCart with ChangeNotifier {
  final int id;
  final String title;
  final String price;
  final String featured_media_url;
  final Brandc brand;
  int productCount;

  final ColorCodeCard color_selected;

  ProductCart(
      {required this.id,
      required this.title,
      required this.price,
      required this.featured_media_url,
      brand,
      required this.productCount,
      color_selected})
      : this.brand = Brandc(id: id, title: title, img_url: ''),
        this.color_selected = ColorCodeCard();

  factory ProductCart.fromJson(Map<String, dynamic> parsedJson) {
    return ProductCart(
      id: parsedJson['id'],
      title: parsedJson['title'],
      price: parsedJson['price'],
      featured_media_url: parsedJson['featured_media_url'],
      brand: Brandc.fromJson(parsedJson['brand']),
      productCount: parsedJson['how_many'],
      color_selected: ColorCodeCard.fromJson(parsedJson['color_selected']),
    );
  }
}
