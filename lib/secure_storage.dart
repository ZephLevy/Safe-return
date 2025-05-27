import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_return/utils/sos_manager.dart';

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
  static Future<void> writeCodes({String? realCode, String? decoyCode}) async {
    await storage.write(key: 'real', value: realCode);
    await storage.write(key: 'decoy', value: decoyCode);
  }

  static Future<void> readCodes() async {
    SosManager.secretCode = await storage.read(key: 'real');
    SosManager.fakeCode = await storage.read(key: 'decoy');
    print("read: ${SosManager.secretCode}");
    print("read: ${SosManager.fakeCode}");
  }
}
