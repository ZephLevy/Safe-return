import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safe_return/logic/codes_logic.dart';

class SecureCodesStorage {
  //initialize

  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
    ),
  );

//storage
  static Future<void> writeCodes({String? realCode, String? decoyCode}) async {
    if (realCode != null) {
      await storage.write(key: 'real', value: realCode);
    }
    if (decoyCode != null) {
      await storage.write(key: 'decoy', value: decoyCode);
    }
  }

  static Future<void> readCodes() async {
    CodesLogic.realCode = await storage.read(key: 'real');
    CodesLogic.decoyCode = await storage.read(key: 'decoy');
  }
}
