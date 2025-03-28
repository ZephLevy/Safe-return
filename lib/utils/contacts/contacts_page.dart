import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:safe_return/pages/settings_page.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:safe_return/utils/contacts/persons.dart';

class ContactsPage extends StatefulWidget {
  final Options item;
  const ContactsPage({required this.item, super.key});

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
            padding: EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: _selectContacts,
                    child: ListTile(
                      leading: Icon(
                        Icons.add,
                        size: 28,
                      ),
                      title: Text("Add"),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: _removeContacts,
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outlined,
                        size: 28,
                      ),
                      title: Text("Remove"),
                    ),
                  )
                ];
              },
            ),
          )
        ],
        title: Text(widget.item.title as String),
      ),
      // bottomNavigationBar: BottomAppBar(),
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
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      Person.persons.removeAt(index);
                      StoredSettings.contactPhone.removeAt(index);
                      StoredSettings.saveContacts(
                          StoredSettings.contactPhone,
                          StoredSettings.contactName,
                          Person.encodePersonString);
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
          if (StoredSettings.contactPhone.contains(phone.number) &&
              context.mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("This contact is already selected!"),
              showCloseIcon: true,
            ));
          } else {
            setState(
              () {
                Person.persons.add(Person(contact.displayName, phone.number));
                // StoredSettings.contactName.add(contact.displayName);
                // StoredSettings.contactPhone.add(phone.number);
                StoredSettings.saveContacts(StoredSettings.contactPhone,
                    StoredSettings.contactName, Person.encodePersonString);
                print("added: ${Person.persons}");
              },
            );
          }
        }
        // print(StoredSettings.contactName);
        // print(StoredSettings.contactPhone);
      }
      setState(() {});
    }
  }

  void _removeContacts() async {
    if (await FlutterContacts.requestPermission()) {
      StoredSettings.loadAll();
//*declared contact info when selected
      final contact = await FlutterContacts.openExternalPick();

      if (contact != null) {
        for (var phone in contact.phones) {
          setState(
            () {
              // StoredSettings.contactPhone.remove(phone.number);
              // StoredSettings.contactName.remove(contact.displayName);
              Person.persons
                  .removeWhere((person) => person.phone == phone.number);
              StoredSettings.saveContacts(StoredSettings.contactPhone,
                  StoredSettings.contactName, Person.encodePersonString);
            },
          );
        }
        print(Person.persons);
        // print(StoredSettings.contactName);
        // print(StoredSettings.contactPhone);
      }
      setState(() {});
    }
  }
}
