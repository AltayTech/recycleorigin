import 'package:flutter/foundation.dart';
import 'package:recycleorigin/core/models/sizes.dart';

import '../../../../core/models/featured_image.dart';

class DriverData with ChangeNotifier {
  final FeaturedImage driver_image;
  final String fname;
  final String lname;
  final String ostan;
  final String city;
  final String phone;
  final String mobile;
  final String address;
  final String postcode;
  final String email;

  DriverData({
    driver_image,
    this.phone = '',
    this.fname = '',
    this.lname = '',
    this.email = '',
    this.ostan = '',
    this.city = '',
    this.mobile = '',
    this.address = '',
    this.postcode = '',
  }) : this.driver_image = FeaturedImage(sizes: Sizes());

  factory DriverData.fromJson(Map<String, dynamic> parsedJson) {
    return DriverData(
      driver_image: parsedJson['driver_image'] != null
          ? FeaturedImage.fromJson(parsedJson['driver_image'])
          : FeaturedImage(
              id: 0,
              title: '',
              sizes: Sizes(
                large: '',
                medium: '',
                thumbnail: '',
              )),
      phone: parsedJson['phone'] != null ? parsedJson['phone'] : '',
      fname: parsedJson['fname'] != null ? parsedJson['fname'] : '',
      lname: parsedJson['lname'] != null ? parsedJson['lname'] : '',
      email: parsedJson['email'] != null ? parsedJson['email'] : '',
      ostan: parsedJson['ostan'] != null ? parsedJson['ostan'] : '',
      city: parsedJson['city'] != null ? parsedJson['city'] : '',
      mobile: parsedJson['mobile'] != null ? parsedJson['mobile'] : '',
      address: parsedJson['address'] != null ? parsedJson['address'] : '',
      postcode: parsedJson['postcode'] != null ? parsedJson['postcode'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'fname': fname,
      'lname': lname,
      'email': email,
      'ostan': ostan,
      'city': city,
      'address_data': address,
      'postcode': postcode,
    };
  }
}
