import 'package:flutter/foundation.dart';
import 'package:recycleorigin/core/network/api_client.dart';

/// Shared [ApiClient] for the customer app (JWT from secure storage).
class ApiProvider {
  ApiProvider._();

  static ApiClient? _client;

  static ApiClient get client => _client ??= ApiClient();

  /// Registers a pre-configured client (e.g. wired to [AuthBloc.invalidateSession]).
  static void register(ApiClient client) {
    _client = client;
  }

  /// Wires [onUnauthorized] before the first API call (e.g. from [AuthBloc]).
  static void init({required VoidCallback onUnauthorized}) {
    _client = ApiClient(onUnauthorized: onUnauthorized);
  }

  static void reset() {
    _client = null;
  }
}
