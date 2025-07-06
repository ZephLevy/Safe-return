import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/logic/screen_logic.dart';
import 'package:safe_return/pages/settings_page.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/utils/persons.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(left: 30),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline),
                  Text("Swipe the contacts left to delete"),
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
        for (var phone in contact.phones) {
          if (Person.persons.any((person) => person.phone == phone.number) &&
              context.mounted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("This contact is already selected!"),
                  showCloseIcon: true,
                ),
              );
            }
          } else {
            setState(
              () {
                Person.persons.add(Person(contact.displayName, phone.number));
                StoredSettings.save(personList: Person.persons);
                SettingsState.sendPersonsList;
              },
            );
          }
        }
      }
    }
  }
}
