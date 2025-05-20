import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:safe_return/utils/persons.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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
              child: Icon(
                Icons.add,
                size: 28,
              ),
            ),
          ),
        ],
        title: Text("Emergency contacts"),
      ),
      //todo bottomNavigationBar: BottomAppBar(),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 600,
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
        ],
      ),
    );
  }

  void _selectContacts() async {
    if (await FlutterContacts.requestPermission()) {
      StoredSettings.loadAll();
//*declared contact info when selected
      final contact = await FlutterContacts.openExternalPick();

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
              },
            );
          }
        }
      }
      setState(() {});
    }
  }
}
