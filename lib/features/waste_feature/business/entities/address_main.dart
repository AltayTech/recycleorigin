import 'package:material_ui/material_ui.dart';

import 'address.dart';

class AddressMain with ChangeNotifier {
  final List<Address> addressData;

  AddressMain({this.addressData = const []});

  factory AddressMain.fromJson(Map<String, dynamic> parsedJson) {
    final raw = parsedJson['address_data'];
    final addressList = raw is List ? raw : <dynamic>[];
    final addressRaw = addressList
        .map((i) => Address.fromJson(i as Map<String, dynamic>))
        .toList();
    return AddressMain(addressData: addressRaw);
  }

  Map<String, dynamic> toJson() {
    List<Map<dynamic, dynamic>>? addressData = this.addressData
        .map((i) => i.toJson())
        .toList();
    return {'address_data': addressData};
  }
}
