import 'package:recycleorigin/features/waste_feature/business/entities/waste_ref.dart';

class ProductOrderReceive {
  final WasteRef product;
  final String number;
  final String total_price;
  final String price;

  ProductOrderReceive({
    product,
    this.number = '1',
    this.total_price = '0.0',
    this.price = '0.0',
  }) : this.product = WasteRef(id: 0, post_title: '');

  factory ProductOrderReceive.fromJson(Map<String, dynamic> parsedJson) {
    return ProductOrderReceive(
      product: WasteRef.fromJson(parsedJson['product']),
      number: parsedJson['number'],
      total_price: parsedJson['total_price'],
      price: parsedJson['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'number': number,
      'total_price': total_price,
      'price': price,
    };
  }
}
