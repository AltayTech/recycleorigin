import 'package:flutter/foundation.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product_order_receive.dart';
import 'package:recycleorigin/core/models/status.dart';

class Order with ChangeNotifier {
  final int id;
  final Status status;
  final String pay_status;
  final String pay_date;
  final String pay_transaction;
  final String send_date;
  final String total_price;
  final String total_number;
  final List<ProductOrderReceive> products;

  Order({
    required this.id,
    required this.status,
    required this.pay_status,
    required this.pay_date,
    required this.pay_transaction,
    required this.send_date,
    required this.total_price,
    required this.total_number,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> parsedJson) {
    var productList = parsedJson['products'] as List;
    List<ProductOrderReceive> productRaw =
        productList.map((i) => ProductOrderReceive.fromJson(i)).toList();

    return Order(
      id: parsedJson['id'],
      status: Status.fromJson(parsedJson['status']),
      pay_status:
          parsedJson['pay_status'] != null ? parsedJson['pay_status'] : '',
      pay_date: parsedJson['pay_date'] != null ? parsedJson['pay_date'] : '',
      pay_transaction: parsedJson['pay_transaction'] != null
          ? parsedJson['pay_transaction']
          : '',
      send_date: parsedJson['send_date'] != null ? parsedJson['send_date'] : '',
      total_price: parsedJson['total_price'],
      total_number: parsedJson['total_number'],
      products: productRaw,
    );
  }
}
