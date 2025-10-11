import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  Future<bool> authenticateWithBiometrics() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e);
    }
    return isAuthenticated;
  }

  static auth(Function isAuthed) async {
    final AuthService authService = AuthService();

    bool isAuthenticated = await authService.authenticateWithBiometrics();
    if (isAuthenticated) {
      isAuthed();
    }
  }
}
