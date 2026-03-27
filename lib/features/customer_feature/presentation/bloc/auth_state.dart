import 'package:equatable/equatable.dart';

enum AuthSubmissionStatus { idle, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthSubmissionStatus.idle,
    this.errorMessage,
  });

  final AuthSubmissionStatus status;
  final String? errorMessage;

  AuthState copyWith({
    AuthSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, errorMessage];
}
