import 'dart:convert';

TokenResponseModel tokenResponseModelFromJson(String str) =>
    TokenResponseModel.fromJson(json.decode(str));
String tokenResponseModelToJson(TokenResponseModel data) =>
    json.encode(data.toJson());

class TokenResponseModel {
  TokenResponseModel({
    String? token,
    String? userEmail,
    String? userNicename,
    String? userDisplayName,
  }) {
    _token = token;
    _userEmail = userEmail;
    _userNicename = userNicename;
    _userDisplayName = userDisplayName;
  }

  TokenResponseModel.fromJson(dynamic json) {
    _token = json['token'].toString();
    _userEmail = json['user_email'].toString();
    _userNicename = json['user_nicename'].toString();
    _userDisplayName = json['user_display_name'].toString();
  }
  String? _token;
  String? _userEmail;
  String? _userNicename;
  String? _userDisplayName;
  TokenResponseModel copyWith({
    String? token,
    String? userEmail,
    String? userNicename,
    String? userDisplayName,
  }) =>
      TokenResponseModel(
        token: token ?? _token,
        userEmail: userEmail ?? _userEmail,
        userNicename: userNicename ?? _userNicename,
        userDisplayName: userDisplayName ?? _userDisplayName,
      );
  String? get token => _token;
  String? get userEmail => _userEmail;
  String? get userNicename => _userNicename;
  String? get userDisplayName => _userDisplayName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['user_email'] = _userEmail;
    map['user_nicename'] = _userNicename;
    map['user_display_name'] = _userDisplayName;
    return map;
  }
}
