import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferredViewer extends StatefulWidget {
  const PreferredViewer({super.key});

  @override
  State<PreferredViewer> createState() => PreferredViewerState();
}

enum ViewType { flutterList, externalList }

class PreferredViewerState extends State<PreferredViewer> {
  static ViewType viewType = ViewType.externalList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preferred Contact Viewer")),
      body: Column(
        children: [
          RadioListTile(
              enableFeedback: true,
              secondary: Icon(
                Icons.contacts,
                size: 35,
              ),
              title: Text(
                "Built-in contacts list",
              ),
              value: ViewType.flutterList,
              groupValue: viewType,
              onChanged: (value) {
                setState(() {
                  viewType = value!;
                  saveViewType();
                });
              }),
          SizedBox(height: 10),
          RadioListTile(
              enableFeedback: true,
              secondary: Icon(
                Icons.open_in_new_rounded,
                size: 35,
              ),
              title: Text("Open contacts app externally"),
              value: ViewType.externalList,
              groupValue: viewType,
              onChanged: (value) {
                setState(() {
                  viewType = value!;
                });
                saveViewType();
              })
        ],
      ),
    );
  }

  Future<void> saveViewType() async {
    final asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString('viewType', viewType.name);
  }

  static Future<void> loadViewType() async {
    final asyncPrefs = SharedPreferencesAsync();
    String? stringViewType = await asyncPrefs.getString('viewType');

    if (stringViewType != null) {
      viewType = ViewType.values.firstWhere(
        (e) => e.name == stringViewType,
        orElse: () => ViewType.externalList,
      );
    }
  }
}
