import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/pages/home_page.dart';

class CheckCodes {
  // void checkCodes() {
  //   NotiService.okVerificationStep = 2;
  //   print(NotiService.okVerificationStep);
  //   if (NotiService.userInput == SosManager.secretCode) {
  //     realCode();
  //   }
  //   if (NotiService.userInput == SosManager.fakeCode) {
  //     decoyCode();
  //   }
  //   if (NotiService.userInput != SosManager.secretCode &&
  //       NotiService.userInput != SosManager.fakeCode) {
  //     wrongCode();
  //   }
  // }

  void realCode() {
    print("[real]");
    NotiService().showNotification(
      id: 0,
      title: "What time?",
      body:
          'Select how long you would like to delay your "Be Back Home By" time.',
      category: NotificationDetails(),
    );
    TimerAndClockState.codeAttempts = 3; //TODO replace 3 with user custom
  }

  void decoyCode() {
    print("[decoy]");
    TimerAndClockState.alert();
    realCode();
  }

  void wrongCode() {
    TimerAndClockState.codeAttempts--;

    if (TimerAndClockState.codeAttempts <= 0) {
      TimerAndClockState.alert();
      NotiService().showNotification(
        id: 0,
        title: "Calling Emergency Contacts",
        body:
            "Too many wrong attempts have triggered an alert to your emergency contacts",
      );
    } else {
      NotiService().showNotification(
        id: 0,
        title: "Try again",
        body:
            "You've entered the wrong code. You have ${TimerAndClockState.codeAttempts} attempts left",
        category: NotificationDetails(),
      );
    }
  }
}
