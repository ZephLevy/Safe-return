import 'dart:convert';

class Person {
  static List<Person> persons = [];
  static String encodedPersonString = '';

  String name;
  String phone;

  @override
  String toString() {
    return 'Person(name: $name, phone: $phone)';
  }

  Person(this.name, this.phone);

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        phone = json['phone'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  static encodePerson(List<Person> targetList) {
    List<Map<String, dynamic>> mappedList = targetList
        .map((person) => person.toJson())
        .toList(); //encodes List of Person objects to List of maps
    encodedPersonString =
        jsonEncode(mappedList); //encodes List of maps into a string
  }

  static void decodePerson(
      {required String toDecode, required List<Person> targetList}) {
    List<dynamic> decodedList =
        jsonDecode(toDecode); //decodes the string into list of maps

    targetList.clear();
    targetList.addAll(decodedList
        .map((item) => Person.fromJson(item))
        .toList()); //decodes list of maps into List of Person objects
  }
}
