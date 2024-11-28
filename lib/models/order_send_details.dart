import 'package:flutter/foundation.dart';

import '../features/store_feature/business/entities/product_order_send.dart';

class OrderSendDetails with ChangeNotifier {
  final String total_price;
  final String total_number;
  final List<ProductOrderSend> products;

  OrderSendDetails({
    required this.total_price,
    required this.total_number,
    required this.products,
  });

  factory OrderSendDetails.fromJson(Map<String, dynamic> parsedJson) {
    var productList = parsedJson['products'] as List;
    List<ProductOrderSend> productRaw = [];

    productRaw = productList.map((i) => ProductOrderSend.fromJson(i)).toList();

    return OrderSendDetails(
      total_price: parsedJson['total_price'],
      total_number: parsedJson['total_number'],
      products: productRaw,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map>? products = this.products != null
        ? this.products.map((i) => i.toJson()).toList()
        : null;

    return {
      'total_price': total_price,
      'total_number': total_number,
      'products': products,
    };
  }
}
