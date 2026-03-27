import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigin/features/customer_feature/presentation/providers/authentication_provider.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authenticationProvider) : super(const AuthState()) {
    on<AuthSubmitted>(_onSubmitted);
    on<AuthResetRequested>(_onResetRequested);
  }

  final AuthenticationProvider _authenticationProvider;

  Future<void> _onSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthSubmissionStatus.loading,
        clearError: true,
      ),
    );

    try {
      if (event.mode == AuthFormMode.login) {
        final bool success =
            await _authenticationProvider.login(event.authData);
        if (!success) {
          emit(
            state.copyWith(
              status: AuthSubmissionStatus.failure,
              errorMessage: 'Code is not correct',
            ),
          );
          return;
        }
      } else {
        final bool registered =
            await _authenticationProvider.register(event.authData);
        if (!registered) {
          emit(
            state.copyWith(
              status: AuthSubmissionStatus.failure,
              errorMessage: 'User already',
            ),
          );
          return;
        }

        final bool loginSuccess =
            await _authenticationProvider.login(event.authData);
        if (!loginSuccess) {
          emit(
            state.copyWith(
              status: AuthSubmissionStatus.failure,
              errorMessage: 'Code is not correct',
            ),
          );
          return;
        }
      }

      emit(
        state.copyWith(
          status: AuthSubmissionStatus.success,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthSubmissionStatus.failure,
          errorMessage: 'Could not authenticate you. Please try again later',
        ),
      );
    }
  }

  void _onResetRequested(
    AuthResetRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState());
  }
}
