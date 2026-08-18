import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/inits/auth_init.dart';
import 'package:safe_return/logic/sos_logic.dart';
import 'package:safe_return/storage.dart/required_settings.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';

class SecurityCodesPage extends StatefulWidget {
  const SecurityCodesPage({super.key});

  @override
  State<SecurityCodesPage> createState() => _SecurityCodesPageState();
}

class _SecurityCodesPageState extends State<SecurityCodesPage> {
  bool noRealCode() => SosLogic.realCode?.isEmpty ?? true;
  bool noDecoyCode() => SosLogic.fakeCode?.isEmpty ?? true;
  final codeKey = GlobalKey<FormState>();
  bool showReal = false;
  bool showDecoy = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Themes.settingsThemeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Security Codes"),
        ),
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                        noRealCode() ? "Set Real Code" : "Change Real Code"),
                    leading:
                        Icon(noRealCode() ? Icons.input : Icons.lock_reset),
                    onTap: () {
                      useBiometricsTo(() {
                        getCodeInput(true);
                      });
                    },
                  ),
                  ListTile(
                    title: Text(
                        noDecoyCode() ? "Set Decoy Code" : "Change Decoy Code"),
                    leading:
                        Icon(noDecoyCode() ? Icons.input : Icons.lock_reset),
                    onTap: () {
                      useBiometricsTo(() {
                        getCodeInput(false);
                      });
                    },
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                title: Text("View Codes"),
                leading: Icon(Icons.visibility),
                onTap: () async {
                  useBiometricsTo(
                    () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            showReal = false;
                            showDecoy = false;
                            return viewCodes();
                          },
                        ),
                      );
                    },
                  );
                },
                trailing: Icon(Icons.arrow_forward_ios_rounded),
              ),
            )
          ],
        ),
      ),
    );
  }

  void useBiometricsTo(Function action) {
    if (StoredSettings.biometricsValue) {
      AuthService.auth(action);
    } else {
      action();
    }
  }

  Widget viewCodes() {
    print("real: ${SosLogic.realCode}");
    print("fake: ${SosLogic.fakeCode}");

    return StatefulBuilder(builder: (context, setModalState) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Your Codes"),
        ),
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Your real code:"),
                  GestureDetector(
                    onTap: () => setModalState(
                      () {
                        showReal = !showReal;
                        showDecoy ? (showDecoy = !showDecoy) : null;
                      },
                    ),
                    child: Text(
                      showReal
                          ? (noRealCode()
                              ? "No real code set"
                              : SosLogic.realCode!)
                          : ('\u2022' * 15),
                      style:
                          TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 12,
              endIndent: 12,
              height: 0,
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Your decoy code:"),
                  GestureDetector(
                    onTap: () => setModalState(
                      () {
                        showDecoy = !showDecoy;
                        showReal ? (showReal = !showReal) : null;
                      },
                    ),
                    child: Text(
                      showDecoy
                          ? (noDecoyCode()
                              ? "No decoy code set"
                              : SosLogic.fakeCode!)
                          : ('\u2022' * 15),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 100, 100, 100)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  void getCodeInput(bool isRealCode) {
    TextEditingController textController = TextEditingController();
    TextEditingController confirmController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isRealCode
              ? "Enter a code"
              : "Enter a code: if threatened to enter a code, this will silently alert your emergency contacts"),
          content: Form(
            key: codeKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLength: 20,
                  autocorrect: false,
                  autofillHints: [AutofillHints.newPassword],
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: isRealCode
                          ? "Enter your real code"
                          : "Enter your decoy code"),
                  validator: (value) {
                    return checkValidNewCode(value, isRealCode);
                  },
                ),
                TextFormField(
                  maxLength: 20,
                  autocorrect: false,
                  autofillHints: [AutofillHints.newPassword],
                  controller: confirmController,
                  decoration: InputDecoration(
                      hintText: isRealCode
                          ? "Confirm your real code"
                          : "Confirm your decoy code"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your code';
                    }
                    if (value != textController.text) {
                      return 'Codes do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                setCodes(isRealCode, textController);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void setCodes(bool isRealCode, TextEditingController textController) async {
    if (codeKey.currentState!.validate()) {
      if (isRealCode) {
        setState(() {
          SosLogic.realCode = textController.text;
        });
        await ReqSettings.saveReq(
            realCode: isRealCode, textController: textController);

        if (!noRealCode()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Your real code has been set!")));
          }
        }
      } else {
        setState(() {
          SosLogic.fakeCode = textController.text;
        });
        await ReqSettings.saveReq(
            realCode: isRealCode, textController: textController);

        if (!noDecoyCode()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Your decoy code has been set!")));
          }
        }
      }
      if (context.mounted) {
        if (mounted) {
          Navigator.of(context).pop();
        }
// Close dialog
      }
    }
  }

  checkValidNewCode(value, realCode) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Code';
    }
    if (value.length < 6) {
      return 'Code must be at least 6 characters';
    }

    if (value.length > 20) {
      return 'Code must be under 20 characters';
    }
    if (realCode) {
      if (value == SosLogic.fakeCode) {
        return 'Real code must be different from decoy code';
      }
    }
    if (value == SosLogic.realCode) {
      return 'Decoy code must be different from real code';
    }
    return null;
  }
}
