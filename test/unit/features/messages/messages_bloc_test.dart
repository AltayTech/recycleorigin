import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigin/features/meassage_feature/presentation/bloc/messages_bloc.dart';

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  group('MessagesBloc', () {
    late MessagesBloc bloc;

    setUp(() => bloc = MessagesBloc());

    tearDown(() async => bloc.close());

    test('createMessage when not logged in completes without throwing',
        () async {
      await bloc.createMessage('Hi', 'Body', '0', '0', false);
      await _tick();
      expect(bloc.allMessages, isEmpty);
    });

    test('getMessages when not logged in completes without throwing', () async {
      await bloc.getMessages('0', false);
      await _tick();
      expect(bloc.allMessages, isEmpty);
    });
  });
}
