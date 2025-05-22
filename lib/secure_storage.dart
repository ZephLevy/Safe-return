import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  //initialize
  static final storage =
      FlutterSecureStorage(aOptions: SecureStorage().getAndroidOptions());
  //ios setup
  final iosOptions = IOSOptions(accessibility: KeychainAccessibility.unlocked);
  //android setup
  AndroidOptions getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

//storage
  static Future<void> writePassword(password) async {
    if (password.length > 50) {
      throw Exception("Value too long for secure storage");
    }
    await storage.write(key: 'password', value: password);
  }

  static Future<void> readPassword() async {
    String? password = await storage.read(key: 'password');
    print("read: $password");
  }
}
