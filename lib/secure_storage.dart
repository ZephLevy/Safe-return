import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final storage = FlutterSecureStorage();
  final options = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static Future<void> write({password}) async {
    if (password.length > 50) {
      throw Exception("Value too long for secure storage");
    }
    await storage.write(key: 'password', value: password);
  }

  static Future<void> read() async {
    String? password = await storage.read(key: 'password');
    print("read: $password");
  }
}
