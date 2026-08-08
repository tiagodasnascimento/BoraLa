import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/features/auth/data/auth_repository.dart';

void main() {
  test('login succeeds with email and password', () async {
    final repository = AuthRepository();

    final user = await repository.login('user@example.com', '123456');

    expect(user.email, 'user@example.com');
    expect(user.name, 'Usuário BoraLá');
  });

  test('login fails with empty credentials', () async {
    final repository = AuthRepository();

    expect(
      () async => repository.login('', ''),
      throwsA(isA<ArgumentError>()),
    );
  });
}
