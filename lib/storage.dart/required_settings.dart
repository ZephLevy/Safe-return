import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/logic/persons_logic.dart';
import 'package:safe_return/logic/sos_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReqSettings {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveReq(
      {List<PersonLogic>? personList,
      LatLng? currentPosition,
      String? realCode,
      String? decoyCode}) async {
    if (personList != null) {
      await asyncPrefs.setString(
          'persons', PersonLogic.encodedPersonString(personList));
    }

    if (currentPosition != null) {
      GetLocation.homePosition = currentPosition;

      await asyncPrefs.setDouble("latitude", currentPosition.latitude);
      await asyncPrefs.setDouble("longitude", currentPosition.longitude);
    }

    if (realCode != null) {
      await asyncPrefs.setString("realCode", realCode);
    }
    if (decoyCode != null) {
      await asyncPrefs.setString("decoyCode", decoyCode);
    }
  }

  static Future<void> loadReq() async {
    String encodedPersonString = await asyncPrefs.getString('persons') ?? "";

    if (encodedPersonString.isNotEmpty) {
      PersonLogic.decodePerson(
          toDecode: encodedPersonString, targetList: PersonLogic.persons);
    }
    double? latitude = await asyncPrefs.getDouble("latitude");
    double? longitude = await asyncPrefs.getDouble("longitude");
    SosLogic.realCode = await asyncPrefs.getString("realCode");
    SosLogic.decoyCode = await asyncPrefs.getString("decoyCode");
    if (latitude != null && longitude != null) {
      GetLocation.homePosition = LatLng(latitude, longitude);
    }
  }
}
