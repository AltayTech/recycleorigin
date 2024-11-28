import 'package:flutter/material.dart';
import 'package:recycleorigin/features/store_feature/business/entities/belongs.dart';
import 'package:recycleorigin/core/models/status.dart';

class Transaction with ChangeNotifier {
  final int id;
  final Status transaction_type;
  final Belongs belongs;
  final String money;
  final String operation;

  Transaction({
    this.id = 1,
    required this.transaction_type,
    required this.belongs,
    this.money = '0.0',
    this.operation = '',
  });

  factory Transaction.fromJson(Map<String, dynamic> parsedJson) {
    return Transaction(
      id: parsedJson['id'],
      money: parsedJson['money'] != null ? parsedJson['money'] : '0',
      operation: parsedJson['operation'] != null ? parsedJson['operation'] : '',
      transaction_type: parsedJson['transaction_type'] != null
          ? Status.fromJson(parsedJson['transaction_type'])
          : Status(name: '', term_id: 0, slug: ''),
      belongs: parsedJson['belongs'] != null
          ? Belongs.fromJson(parsedJson['belongs'])
          : Belongs(id: 0, name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    Map? transaction_type = this.transaction_type.toJson();
    Map? belongs = this.belongs.toJson();

    return {
      'id': id,
      'money': money,
      'operation': operation,
      'transaction_type': transaction_type,
      'belongs': belongs,
    };
  }
}
