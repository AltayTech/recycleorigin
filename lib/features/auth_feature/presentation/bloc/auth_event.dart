import 'dart:async';

import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';

/// Base event class for auth bloc.
abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.authData,
    required this.completer,
  });

  final Map<String, String> authData;
  final Completer<bool> completer;
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.authData,
    required this.completer,
  });

  final Map<String, String> authData;
  final Completer<bool> completer;
}

class AuthTokenLoadRequested extends AuthEvent {
  const AuthTokenLoadRequested({
    this.completer,
  });

  final Completer<void>? completer;
}

class AuthCompletionCheckRequested extends AuthEvent {
  const AuthCompletionCheckRequested({
    this.completer,
  });

  final Completer<void>? completer;
}

class AuthTokenRemoved extends AuthEvent {
  const AuthTokenRemoved({
    this.completer,
  });

  final Completer<void>? completer;
}

class AuthAddressesLoadRequested extends AuthEvent {
  const AuthAddressesLoadRequested({
    this.completer,
  });

  final Completer<void>? completer;
}

class AuthAddressUpdateRequested extends AuthEvent {
  const AuthAddressUpdateRequested({
    required this.addresses,
    this.completer,
  });

  final List<Address> addresses;
  final Completer<void>? completer;
}

class AuthOrderRequested extends AuthEvent {
  const AuthOrderRequested({
    required this.addresses,
    this.completer,
  });

  final List<Address> addresses;
  final Completer<void>? completer;
}

class AuthAddressSelected extends AuthEvent {
  const AuthAddressSelected(this.address);

  final Address address;
}

class AuthRegionsLoadRequested extends AuthEvent {
  const AuthRegionsLoadRequested({
    this.completer,
  });

  final Completer<void>? completer;
}

class AuthRegionsByCityLoadRequested extends AuthEvent {
  const AuthRegionsByCityLoadRequested({
    required this.cityId,
    this.completer,
  });

  final int cityId;
  final Completer<void>? completer;
}

class AuthRegionLoadRequested extends AuthEvent {
  const AuthRegionLoadRequested({
    required this.regionId,
    this.completer,
  });

  final int regionId;
  final Completer<void>? completer;
}

class AuthFirstLoginFlagChanged extends AuthEvent {
  const AuthFirstLoginFlagChanged(this.value);

  final bool value;
}

class AuthFirstLogoutFlagChanged extends AuthEvent {
  const AuthFirstLogoutFlagChanged(this.value);

  final bool value;
}

class AuthLoggedInFlagChanged extends AuthEvent {
  const AuthLoggedInFlagChanged(this.value);

  final bool value;
}
