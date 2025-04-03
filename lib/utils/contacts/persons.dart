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

  static void encodePerson() {
    List<Map<String, dynamic>> encodedPersonList = persons
        .map((person) => person.toJson())
        .toList(); //encodes List of Person objects to List of maps
    encodedPersonString =
        jsonEncode(encodedPersonList); //encodes List of maps into a string
  }

  static void decodePerson() {
    List<dynamic> decodePersonList =
        jsonDecode(encodedPersonString); //decodes the string into list of maps
    persons = decodePersonList
        .map((item) => Person.fromJson(item))
        .toList(); //decodes list of maps into List of Person objects
  }
}
