import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/logic/persons_logic.dart';
import 'package:safe_return/pages/all_settings_pages/preferred_viewer_page.dart';
import 'package:safe_return/storage.dart/required_settings.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  bool isEditing = false;
  bool _contactsLoading = false;
  Set<PersonLogic> selectedEditableItems = {};
  Duration snackbarDuration = Duration(milliseconds: 0);
  int singleBarMs = 2000;

  void addToDuration(int n) {
    snackbarDuration = Duration(milliseconds: singleBarMs * n);
  }

  void removeToDuration() {
    snackbarDuration =
        Duration(milliseconds: snackbarDuration.inMilliseconds - singleBarMs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 25, top: 3),
              child: SizedBox(
                height: 48,
                width: 48,
                child: Center(
                  child: PersonLogic.persons.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(
                              () {
                                isEditing = !isEditing;
                                selectedEditableItems = {};
                              },
                            );
                          },
                          isSelected: isEditing,
                          icon: Icon(Icons.edit_outlined),
                          selectedIcon: Icon(Icons.check),
                        )
                      : _contactsLoading
                          ? CircularProgressIndicator.adaptive()
                          : IconButton(
                              tooltip:
                                  "How on earth do you not know what a + button does \n[add_emergency_contact]",
                              onPressed: () => _selectContacts(),
                              icon: Icon(
                                Icons.add,
                                size: 28,
                              ),
                            ),
                ),
              ),
            ),
          ],
          title: Text("Emergency contacts"),
        ),
        bottomNavigationBar: SizedBox(
          height: 90,
          child: Container(
            width: double.infinity,
            height: 90,
            color: Palette.backgroundColor,
            // decoration: BoxDecoration(
            //   color: Palette.backgroundColor,
            //   boxShadow: [
            //     BoxShadow(
            //       color: const Color.fromARGB(255, 195, 11, 228),
            //       offset: Offset(0, -1),
            //       blurRadius: 15,
            //       spreadRadius: 25,
            //     )
            //   ],
            // ),
            child: isEditing
                ? Row(
                    spacing: 160,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        iconSize: 30,
                        icon: Icon(
                          Icons.delete_outline,
                        ),
                        onPressed: () {
                          setState(() {
                            PersonLogic.persons.removeWhere((person) =>
                                selectedEditableItems.contains(person));
                          });
                          addToDuration(selectedEditableItems.length);
                          for (var i in selectedEditableItems) {
                            removeToDuration();

                            showTopSnackBar(
                                displayDuration: snackbarDuration,
                                dismissType: DismissType.onSwipe,
                                Overlay.of(context),
                                CustomSnackBar.error(
                                    icon: Icon(
                                      Icons.cancel_outlined,
                                      color: Color(0x15000000),
                                      size: 120,
                                    ),
                                    message: "Removed: ${i.name}, ${i.phone}"));
                          }
                          selectedEditableItems.clear();
                          ReqSettings.saveReq(personList: PersonLogic.persons);
                          if (PersonLogic.persons.isEmpty) {
                            setState(() {
                              isEditing = false;
                            });
                          }
                        },
                      ),
                      IconButton(
                          iconSize: 30,
                          onPressed: () => _selectContacts(),
                          icon: _contactsLoading
                              ? CircularProgressIndicator.adaptive()
                              : Icon(Icons.add)),
                    ],
                  )
                : null,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: PersonLogic.persons.isEmpty
                    ? contactListInfo()
                    : listView(),
              ),
            ),
            // deleteInfo()
          ],
        ));
  }

  Widget contactListInfo() {
    return Padding(
      key: ValueKey('visible'),
      padding: const EdgeInsets.only(top: 70),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                softWrap: true,
                'This is your Emergency Contacts list.'),
            SizedBox(height: 8),
            Text(
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
                softWrap: true,
                'Click the "+" button on the top-right to add Emergency Contacts. \n\nIf you are not home by the time you select, all these contacts will be alerted (varies based on your configuration).'),
          ],
        ),
      ),
    );
  }

  Widget listView() {
    return ListView.separated(
      physics: PersonLogic.persons.isEmpty
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      itemCount: PersonLogic.persons.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return isEditing ? editingTile(index) : dismissibleTile(index);
      },
    );
  }

  Widget editingTile(index) {
    PersonLogic personAtIndex = PersonLogic.persons[index];
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ListTile(
        title: Text(
          PersonLogic.persons[index].name,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        trailing: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(PersonLogic.persons[index].phone),
              Checkbox(
                value: (selectedEditableItems.contains(personAtIndex)),
                onChanged: (value) {
                  if (value == true) {
                    setState(() {
                      selectedEditableItems.add(personAtIndex);
                    });
                  } else {
                    setState(() {
                      selectedEditableItems.remove(personAtIndex);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dismissibleTile(index) {
    return Dismissible(
      key: Key(PersonLogic.persons[index].phone),
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
          PersonLogic.persons.removeAt(index);
          ReqSettings.saveReq(personList: PersonLogic.persons);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: ListTile(
          title: Text(PersonLogic.persons[index].name),
          trailing: Text(PersonLogic.persons[index].phone),
        ),
      ),
    );
  }

  Widget deleteInfo() {
    return Align(
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: PersonLogic.persons.isNotEmpty
            ? Container(
                key: ValueKey(
                    'visible'), // Required for AnimatedSwitcher to work properly
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
              )
            : SizedBox.shrink(
                key: ValueKey('hidden')), //Empty widget when not visible,
      ),
    );
  }

  Future<void> _selectContacts() async {
    if (Platform.isAndroid &&
        PreferredViewerState.viewType == ViewType.flutterList) {
      setState(() => _contactsLoading = true);
      final allContacts = await FlutterContacts.getContacts(
          withPhoto: true, withThumbnail: true, withProperties: true);

      setState(() => _contactsLoading = false);
      pushToAndroidContacts(allContacts);
    } else {
      setState(() {
        _contactsLoading = true;
      });
      if (await FlutterContacts.requestPermission()) {
        if (Platform.isIOS) {
          final contact = await FlutterContacts.openExternalPick();

          setState(() {
            _contactsLoading = false;
          });

          handleNumPhones(contact);
        }
      }
    }
  }

  void handleNumPhones(Contact? contact) {
    if (contact != null) {
      if (contact.phones.length >= 2) {
        multiplePhones(contact);
      } else {
        handleAddContacts(contact, null, addAll: true);
      }
    }
  }

  pushToAndroidContacts(List<Contact> allContacts) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return androidContactList(allContacts);
        },
      ),
    );
  }

  Widget androidContactList(List<Contact> allContacts) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            final contact = allContacts[index];
            return ListTile(
              title: Text(contact.displayName),
              onTap: () {
                Navigator.pop(context);
                handleNumPhones(contact);
              },
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: allContacts.length),
    );
  }

  void multiplePhones(Contact contact) {
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
                    handleAddContacts(contact, selectedPhones, addAll: true);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                    }
                  },
                  child: Text("Add all")),
              TextButton(
                  onPressed: () {
                    handleAddContacts(contact, selectedPhones, addAll: false);
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

  void handleAddContacts(Contact contact, Set<Phone>? selectedPhones,
      {bool? addAll}) {
    if (addAll != null) {
      var phoneList =
          addAll ? contact.phones : selectedPhones ?? contact.phones;

      addToDuration(phoneList.length);

      for (Phone phone in (phoneList)) {
        removeToDuration();

        if (PersonLogic.persons.any((person) => person.phone == phone.number) &&
            context.mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     duration: Duration(seconds: 3),
          //     content: Text(
          //       "The phone number ${phone.number} has already been added for ${contact.displayName}",
          //       softWrap: true,
          //     ),
          //     showCloseIcon: true,
          //   ),
          // );
          duplicateContact(phone, contact);
        } else {
          setState(
            () {
              PersonLogic.persons
                  .add(PersonLogic(contact.displayName, phone.number));
              PersonLogic.persons.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
              ReqSettings.saveReq(personList: PersonLogic.persons);
              sendPersonsList;
            },
          );
          showTopSnackBar(
            displayDuration: snackbarDuration,
            dismissType: DismissType.onSwipe,
            Overlay.of(context),
            CustomSnackBar.info(
              icon: Icon(Icons.info_outline_rounded,
                  color: Color(0x15000000), size: 120),
              message: "Added: ${contact.displayName}, ${phone.number}",
            ),
          );
        }
      }
    }
  }

  static Future<void> sendPersonsList() async {
    print(PersonLogic.encodedPersonString(PersonLogic.persons));

    const ip = String.fromEnvironment("IP");

    try {
      if (ip == "") {
        print("No ip passed to CLI when run");
      }

      Uri url = Uri.parse('http://$ip/'); //TODO fix to correct endpoint
      final serverResponse = await http.post(url, body: {
        'personsList': PersonLogic.encodedPersonString(PersonLogic.persons)
      });

      if (serverResponse.statusCode == 200) {
        print(
            "serverResponse.statusCode = ${serverResponse.statusCode} \nServer received request.");
      } else {
        print(
            "serverResponse.statusCode = ${serverResponse.statusCode} \nServer failed to receive persons list.");
      }
    } catch (e) {
      print("Could not connect to server/server not running");
    }
  }

  void duplicateContact(Phone phone, Contact contact) {
    showTopSnackBar(
      displayDuration: snackbarDuration,
      dismissType: DismissType.onSwipe,
      Overlay.of(context),
      CustomSnackBar.error(
        message:
            "The phone number ${phone.number} has already been added for ${contact.displayName}",
      ),
    );
  }
}
