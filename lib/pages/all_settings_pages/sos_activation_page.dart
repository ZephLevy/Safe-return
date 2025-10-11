import 'package:flutter/material.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/logic/screen_logic.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';
import 'package:safe_return/logic/sos_logic.dart';

class SosActivationPage extends StatefulWidget {
  const SosActivationPage({super.key});

  @override
  State<SosActivationPage> createState() => SosActivationPageState();
}

class SosActivationPageState extends State<SosActivationPage> {
  final dditems = [
    'Single Click',
    'Double Click',
    'Triple Click',
    'Quad-Click',
  ];
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text("SOS Activation"),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(
                    height: 0,
                  ),
                  itemCount: dditems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      minTileHeight: 65,
                      title: Text(dditems[index]),
                      trailing: StoredSettings.selectedIndex == index
                          ? Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.blue.shade600,
                              ),
                            )
                          : null,
                      onTap: () => setState(
                        () {
                          StoredSettings.selectedIndex = index;
                          SosLogic.clickN = StoredSettings.selectedIndex + 1;
                          StoredSettings.save(
                              selectedIndex: StoredSettings.selectedIndex,
                              clickN: SosLogic.clickN);
                        },
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 30, top: 10, right: 10, bottom: 40),
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
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SizedBox(
                          width:
                              ScreenLogic.screenWidth(context) - 30 - 10 - 40,
                          child: Text(
                              softWrap: true,
                              "This determines the number of clicks required to activate the SOS button in the Home Page."),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
