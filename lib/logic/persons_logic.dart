import 'dart:convert';

class PersonLogic {
  static List<PersonLogic> persons = [];
  static String encodedPersonString(personList) {
    return encodePerson(personList);
  }

  String name;
  String phone;

  @override
  String toString() {
    return 'Person(name: $name, phone: $phone)';
  }

  PersonLogic(this.name, this.phone);

  PersonLogic.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        phone = json['phone'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  static encodePerson(List<PersonLogic> targetList) {
    List<Map<String, dynamic>> mappedList = targetList
        .map((person) => person.toJson())
        .toList(); //encodes List of Person objects to List of maps
    return jsonEncode(mappedList); //encodes List of maps into a string
  }

  static void decodePerson(
      {required String toDecode, required List<PersonLogic> targetList}) {
    List<dynamic> decodedList =
        jsonDecode(toDecode); //decodes the string into list of maps

    targetList.clear();
    targetList.addAll(decodedList
        .map((item) => PersonLogic.fromJson(item))
        .toList()); //decodes list of maps into List of Person objects
  }
}
