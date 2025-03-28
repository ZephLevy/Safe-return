import 'dart:convert';
import 'package:safe_return/utils/stored_settings.dart';

class Person {
  static List<Person> persons = [];

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
  static List<Map<String, dynamic>> encodePersonsList = persons
      .map((person) => person.toJson())
      .toList(); //encodes List of Person objects to List of maps
  static String encodePersonString =
      jsonEncode(encodePersonsList); //encodes List of maps into a string

  static List<dynamic> decodePersonsList =
      jsonDecode(encodePersonString); //decodes the string into list of maps
  static List<Person> decodePersonsString = encodePersonsList
      .map((item) => Person.fromJson(item))
      .toList(); //decodes list of maps into List of Person objects
}
