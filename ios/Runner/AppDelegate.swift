import Flutter
import flutter_local_notifications
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // setting up interactive notification

        let notiCenter = UNUserNotificationCenter.current()
        notiCenter.delegate = self
        notiCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                // input your security code in this notification
                let codeTextAction = UNTextInputNotificationAction(
                    identifier: "REPLY_ACTION",
                    title: "",
                    options: [],
                    textInputButtonTitle: "Enter",
                    textInputPlaceholder: "Enter your code"
                )
                let codeTextCategory = UNNotificationCategory(
                    identifier: "TEXT_INPUT_CATEGORY",
                    actions: [codeTextAction],
                    intentIdentifiers: [],
                    options: []
                )

                // set the time for which to delay the notification for, if real code is inputed before
                let delayingActions: [UNNotificationAction] = [
                    UNNotificationAction(
                        identifier: "15_MINS",
                        title: "Extend for 15 minutes",
                        options: []
                    ),
                    UNNotificationAction(
                        identifier: "1_HOUR",
                        title: "Extend for 1 hour",
                        options: []
                    ),
                ]
                let delayCategory = UNNotificationCategory(
                    identifier: "DELAY_ACTIONS_CATEGORY",
                    actions: delayingActions,
                    intentIdentifiers: [],
                    options: []
                )
                notiCenter.setNotificationCategories([codeTextCategory, delayCategory])
            }
        }

        // set up notification
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // handling what happends after text input
    override func userNotificationCenter(_: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void)
    {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            completionHandler()
            return
        }

        let channel = FlutterMethodChannel(name: "notification_channel", binaryMessenger: controller.binaryMessenger)

        switch response.actionIdentifier {
        case "REPLY_ACTION":
            if let codeTextResponse = response as? UNTextInputNotificationResponse {
                let userCode = codeTextResponse.userText
                channel.invokeMethod("onCodeInput", arguments: userCode)
            }

        case "15_MINS", "1_HOUR":
            channel.invokeMethod("onActionSelected", arguments: response.actionIdentifier)

        default:
            break
        }

        completionHandler()
    }
}
