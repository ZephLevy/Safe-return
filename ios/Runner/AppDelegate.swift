import background_locator_2
import Flutter
import flutter_local_notifications
import UIKit

func registerPlugins(registry: FlutterPluginRegistry) {
    if !registry.hasPlugin("BackgroundLocatorPlugin") {
        GeneratedPluginRegistrant.register(with: registry)
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        // Register all Flutter plugins for normal lifecycle
        GeneratedPluginRegistrant.register(with: self)

        // Set the plugin registrant callback for background_locator isolate
        BackgroundLocatorPlugin.setPluginRegistrantCallback(registerPlugins)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
