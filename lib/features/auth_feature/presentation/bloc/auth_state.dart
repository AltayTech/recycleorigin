import 'package:recycleorigin/core/models/region.dart';
import 'package:recycleorigin/features/auth_feature/data/models/TokenResponseModel.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';

/// Immutable authentication state for the customer app.
class AuthState {
  AuthState({
    this.token = '',
    TokenResponseModel? tokenResponseModel,
    this.isLoggedIn = false,
    this.isFirstLogin = false,
    this.isFirstLogout = false,
    this.isCompleted = false,
    List<Address>? addressItems,
    Address? selectedAddress,
    List<Region>? regionItems,
    this.regionData,
  })  : tokenResponseModel = tokenResponseModel ?? TokenResponseModel(),
        addressItems = addressItems ?? <Address>[],
        selectedAddress = selectedAddress ?? Address(region: Region()),
        regionItems = regionItems ?? <Region>[];

  final String token;
  final TokenResponseModel tokenResponseModel;
  final bool isLoggedIn;
  final bool isFirstLogin;
  final bool isFirstLogout;
  final bool isCompleted;
  final List<Address> addressItems;
  final Address selectedAddress;
  final List<Region> regionItems;
  final Region? regionData;

  bool get isAuth => token.isNotEmpty;

  AuthState copyWith({
    String? token,
    TokenResponseModel? tokenResponseModel,
    bool? isLoggedIn,
    bool? isFirstLogin,
    bool? isFirstLogout,
    bool? isCompleted,
    List<Address>? addressItems,
    Address? selectedAddress,
    List<Region>? regionItems,
    Region? regionData,
  }) {
    return AuthState(
      token: token ?? this.token,
      tokenResponseModel: tokenResponseModel ?? this.tokenResponseModel,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      isFirstLogout: isFirstLogout ?? this.isFirstLogout,
      isCompleted: isCompleted ?? this.isCompleted,
      addressItems: addressItems ?? this.addressItems,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      regionItems: regionItems ?? this.regionItems,
      regionData: regionData ?? this.regionData,
    );
  }
}
