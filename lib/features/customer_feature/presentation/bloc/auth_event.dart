import 'package:equatable/equatable.dart';

enum AuthFormMode { login, registration }

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthSubmitted extends AuthEvent {
  const AuthSubmitted({
    required this.mode,
    required this.authData,
  });

  final AuthFormMode mode;
  final Map<String, String> authData;

  @override
  List<Object?> get props => <Object?>[mode, authData];
}

class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}
