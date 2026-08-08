import '../domain/user.dart';

class AuthRepository {
  Future<UserSession> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email e senha são obrigatórios.');
    }

    return UserSession(
      id: 'user_001',
      name: 'Usuário BoraLá',
      email: email,
    );
  }
}
