import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/core/models/region.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:recycleorigin/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/address.dart';

import '../../../helpers/mock_api_client.dart';

void main() {
  group('AuthBloc', () {
    late MockApiClient mockApi;

    setUp(() {
      mockApi = MockApiClient();
    });

    blocTest<AuthBloc, AuthState>(
      'emits updated state when first-login flag changes',
      build: () => AuthBloc(mockApi),
      act: (bloc) => bloc.add(const AuthFirstLoginFlagChanged(true)),
      expect: () => [
        isA<AuthState>().having((s) => s.isFirstLogin, 'isFirstLogin', true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits updated state when logged-in flag changes',
      build: () => AuthBloc(mockApi),
      act: (bloc) => bloc.add(const AuthLoggedInFlagChanged(true)),
      expect: () => [
        isA<AuthState>().having((s) => s.isLoggedIn, 'isLoggedIn', true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits updated selected address',
      build: () => AuthBloc(mockApi),
      act: (bloc) {
        final next = Address(
          name: 'Home',
          address: '1 Test St',
          region: Region(term_id: 1, name: 'R1', collect_hour: const []),
        );
        bloc.add(AuthAddressSelected(next));
      },
      expect: () => [
        isA<AuthState>().having(
          (s) => s.selectedAddress.name,
          'address name',
          'Home',
        ),
      ],
    );
  });
}
