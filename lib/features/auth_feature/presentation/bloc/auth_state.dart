import 'package:recycleorigin/core/models/region.dart';
import 'package:recycleorigin/features/auth_feature/data/models/TokenResponseModel.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';

/// Immutable authentication state for the customer app.
///
/// Notable fields:
///   - [token]: backend access JWT (short-lived).
///   - [refreshToken]: opaque rotating refresh token (30 days).
///   - [emailVerified]: mirrors the backend `email_verified` claim and is
///     used by the UI to gate sensitive features behind the verification
///     screen.
///   - [provider]: how the user authenticated (`password`, `google.com`).
class AuthState {
  AuthState({
    this.token = '',
    this.refreshToken = '',
    TokenResponseModel? tokenResponseModel,
    this.isLoggedIn = false,
    this.isFirstLogin = false,
    this.isFirstLogout = false,
    this.isCompleted = false,
    this.emailVerified = false,
    this.provider = '',
    this.role = '',
    List<Address>? addressItems,
    Address? selectedAddress,
    List<Region>? regionItems,
    this.regionData,
  }) : tokenResponseModel = tokenResponseModel ?? TokenResponseModel(),
       addressItems = addressItems ?? <Address>[],
       selectedAddress = selectedAddress ?? Address(region: Region()),
       regionItems = regionItems ?? <Region>[];

  final String token;
  final String refreshToken;
  final TokenResponseModel tokenResponseModel;
  final bool isLoggedIn;
  final bool isFirstLogin;
  final bool isFirstLogout;
  final bool isCompleted;
  final bool emailVerified;
  final String provider;
  final String role;
  final List<Address> addressItems;
  final Address selectedAddress;
  final List<Region> regionItems;
  final Region? regionData;

  bool get isAuth => token.isNotEmpty;

  AuthState copyWith({
    String? token,
    String? refreshToken,
    TokenResponseModel? tokenResponseModel,
    bool? isLoggedIn,
    bool? isFirstLogin,
    bool? isFirstLogout,
    bool? isCompleted,
    bool? emailVerified,
    String? provider,
    String? role,
    List<Address>? addressItems,
    Address? selectedAddress,
    List<Region>? regionItems,
    Region? regionData,
  }) {
    return AuthState(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenResponseModel: tokenResponseModel ?? this.tokenResponseModel,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      isFirstLogout: isFirstLogout ?? this.isFirstLogout,
      isCompleted: isCompleted ?? this.isCompleted,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider ?? this.provider,
      role: role ?? this.role,
      addressItems: addressItems ?? this.addressItems,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      regionItems: regionItems ?? this.regionItems,
      regionData: regionData ?? this.regionData,
    );
  }
}
