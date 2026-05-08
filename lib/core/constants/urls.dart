import 'package:recycleorigin/core/config/app_config.dart';

/// API URL constants. [baseUrl] and [rootUrl] use [AppConfig.apiBaseUrl]
/// so the app talks to the correct backend (set API_BASE_URL in .env; no /rest suffix).
class Urls {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get rootUrl => baseUrl + 'pasmands/v1';

  static const pasmandsEndPoint = '/pasmands';
  static const productsEndPoint = '/products';
  static const categoriesEndPoint = '/products/category';
  static const addressEndPoint = '/customer/address';
  static const regionEndPoint = '/customer/regions';
  static const countriesEndPoint = '/countries';
  static const articlesEndPoint = '/articles';
  static const articlesCatEndPoint = '/articles/category';
  static const collectsEndPoint = '/collects';

  /// POST body: `{ "score": 1-5, "comment": "optional" }`
  static String collectRatePath(int collectId) =>
      '$collectsEndPoint/$collectId/rate';
  static const checkCompletedEndPoint = '/customer/completed';
  static const customerEndPoint = '/customer';
  static const orderEndPoint = '/orders';
  static const transactionsEndPoint = '/transactions';
  static const provincesEndPoint = '/provinces';
  static const typesEndPoint = '/customer/types';
  static const clearingEndPoint = '/clearings';
  static const walletEndPoint = '/wallet';
  static const walletTransactionsEndPoint = '/wallet/transactions';
  static const walletWithdrawEndPoint = '/wallet/withdraw';

  static const shopEndPoint = '/info';
  static const messageEndPoint = '/messages';

  static const loginEndPoint = 'jwt-auth/v1/token';
  static const registerEndPoint = 'pasmands/v1/auth/register';

  /// POST { id_token } - exchanges a Firebase ID token for a backend access
  /// + refresh token pair. Returned by [Urls.firebaseExchangeEndPoint].
  static const firebaseExchangeEndPoint = 'pasmands/v1/auth/firebase';

  /// POST { refresh_token } - rotates the refresh token and returns a fresh
  /// access + refresh pair.
  static const refreshTokenEndPoint = 'pasmands/v1/auth/refresh';

  /// POST { refresh_token, all? } - revokes the refresh token (or all
  /// sessions for the user when `all=true`). Requires a valid access token.
  static const logoutEndPoint = 'pasmands/v1/auth/logout';

  /// GET - returns the currently authenticated user record (requires JWT).
  static const meEndPoint = 'pasmands/v1/auth/me';

  static const sendMessageEndPoint = '/customer/send_message';
  static const orderInfoEndPoint = '/order';
  static const payEndPoint = '/pay';
}
