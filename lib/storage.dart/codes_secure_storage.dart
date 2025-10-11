import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_return/logic/sos_logic.dart';

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
    SosLogic.secretCode = await storage.read(key: 'real');
    SosLogic.fakeCode = await storage.read(key: 'decoy');
    print("read: ${SosLogic.secretCode}");
    print("read: ${SosLogic.fakeCode}");
  }
}
