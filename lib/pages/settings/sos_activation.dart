import 'package:flutter/material.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/utils/sos_manager.dart';

class SosActivation extends StatefulWidget {
  const SosActivation({super.key});

  @override
  State<SosActivation> createState() => SosActivationState();
}

class SosActivationState extends State<SosActivation> {
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
          body: ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(
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
                    SosManager.clickN = StoredSettings.selectedIndex + 1;
                    StoredSettings.save(
                        selectedIndex: StoredSettings.selectedIndex,
                        clickN: SosManager.clickN);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
