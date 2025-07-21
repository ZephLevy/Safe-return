import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/utils/persons.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  bool _contactsLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //todo center add icon with title and back button
        //? modify back button
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 32),
            child: InkWell(
              radius: 24,
              borderRadius: BorderRadius.circular(20),
              onTap: _selectContacts,
              child: _contactsLoading
                  ? CircularProgressIndicator()
                  : Icon(
                      Icons.add,
                      size: 28,
                    ),
            ),
          ),
        ],
        title: Text("Emergency contacts"),
      ),
      //TODO bottomNavigationBar: BottomAppBar(), not sure if to keep this anymore
      //TODO add an edit button or something so the user has another way to delete the contacts since swiping is too unintuitive
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: Person.persons.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(Person.persons[index].phone),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      Person.persons.removeAt(index);
                      StoredSettings.save(personList: Person.persons);
                    });
                  },
                  child: ListTile(
                    title: Text(Person.persons[index].name),
                    trailing: Text(Person.persons[index].phone),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.only(left: 30, top: 10),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Palette.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, -1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text("Swipe the contacts left to delete"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _selectContacts() async {
    setState(() {
      _contactsLoading = true;
    });
    if (await FlutterContacts.requestPermission()) {
//*declared contact info when selected
      final contact = await FlutterContacts.openExternalPick();
      setState(() {
        _contactsLoading = false;
      });

      if (contact != null) {
        if (contact.phones.length >= 2) {
          multiplePhones(contact);
        } else {
          onePhone(contact);
        }
      }
    }
  }

  void onePhone(Contact contact) {
    for (var phone in contact.phones) {
      if (Person.persons.any((person) => person.phone == phone.number) &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              "The phone number ${phone.number} has already been added for ${contact.displayName}",
              softWrap: true,
            ),
            showCloseIcon: true,
          ),
        );
      } else {
        setState(
          () {
            Person.persons.add(Person(contact.displayName, phone.number));
            Person.persons.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
            StoredSettings.save(personList: Person.persons);
            sendPersonsList;
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              "Added: ${contact.displayName}, ${phone.number}",
              softWrap: true,
            ),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  void multiplePhones(Contact contact) {
    bool? addAll;
    if (!mounted) return;
    final selectedPhones = <Phone>{};
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
            titlePadding: EdgeInsets.only(left: 24, top: 0, right: 0),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "${contact.displayName} has multiple phone numbers",
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  child: IconButton(
                    tooltip: "Close",
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
            contentPadding:
                EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 0),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                        "Select which of ${contact.displayName}'s phone numbers you would like to use."),
                  ),
                  Divider(
                    height: 2,
                    indent: 0,
                    endIndent: 0,
                    thickness: 2,
                    radius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          final phone = contact.phones[index];
                          final isSelected = selectedPhones.contains(phone);
                          return ListTile(
                            title: Text(phone.number),
                            trailing:
                                isSelected ? Icon(Icons.check_rounded) : null,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedPhones.remove(phone);
                                } else {
                                  selectedPhones.add(phone);
                                }
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: contact.phones.length),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    addAll = true;
                    handleAddMultipleContacts(contact, selectedPhones, addAll);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                    }
                  },
                  child: Text("Add all")),
              TextButton(
                  onPressed: () {
                    addAll = false;
                    handleAddMultipleContacts(contact, selectedPhones, addAll);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                    }
                  },
                  child: Text("Done"))
            ],
          );
        });
      },
    );
  }

  void handleAddMultipleContacts(
      Contact contact, Set<Phone> selectedPhones, bool? addAll) {
    if (addAll != null) {
      for (var phone in addAll ? contact.phones : selectedPhones) {
        if (Person.persons.any((person) => person.phone == phone.number) &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                "The phone number ${phone.number} has already been added for ${contact.displayName}",
                softWrap: true,
              ),
              showCloseIcon: true,
            ),
          );
        } else {
          setState(
            () {
              Person.persons.add(Person(contact.displayName, phone.number));
              Person.persons.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
              StoredSettings.save(personList: Person.persons);
              sendPersonsList;
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                "Added: ${contact.displayName}, ${phone.number}",
                softWrap: true,
              ),
              showCloseIcon: true,
            ),
          );
        }
      }
    }
  }

  static Future<void> sendPersonsList() async {
    Person.encodePerson(Person.persons);
    const ip = String.fromEnvironment("IP");
    Uri url = Uri.parse(
        'http://$ip/auth/verify-email'); //TODO fix to correct endpoint
    final serverResponse =
        await http.post(url, body: {'personsList': Person.encodedPersonString});

    if (serverResponse.statusCode == 200) {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer received request.");
    } else {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer failed to receive request.");
    }
  }
}
