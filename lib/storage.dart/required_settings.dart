import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/logic/persons_logic.dart';
import 'package:safe_return/logic/sos_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReqSettings {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveReq({
    List<PersonLogic>? personList,
    LatLng? currentPosition,
    bool? realCode,
    TextEditingController? textController,
  }) async {
    if (personList != null) {
      await asyncPrefs.setString(
          'persons', PersonLogic.encodedPersonString(personList));
    }

    if (currentPosition != null) {
      GetLocation.homePosition = currentPosition;

      await asyncPrefs.setDouble("latitude", currentPosition.latitude);
      await asyncPrefs.setDouble("longitude", currentPosition.longitude);
    }

    if (realCode != null && textController != null) {
      if (realCode) {
        await asyncPrefs.setString("secretCode", textController.text);
      } else {
        await asyncPrefs.setString("fakeCode", textController.text);
      }
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
    SosLogic.realCode = await asyncPrefs.getString("secretCode");
    SosLogic.fakeCode = await asyncPrefs.getString("fakeCode");
    if (latitude != null && longitude != null) {
      GetLocation.homePosition = LatLng(latitude, longitude);
    }
  }
}
