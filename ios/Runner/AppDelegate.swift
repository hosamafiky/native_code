import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "battery_channel", binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler { call, result in
            switch call.method {
              case "getBatteryLevel":
                  result(self.getBatteryLevel())
              case "getBatteryState":
                  result(self.getBatteryState())
              default:
                  result(FlutterMethodNotImplemented)
            }
        }

        let batteryLevelChannel = FlutterEventChannel(name: "battery_level_channel", binaryMessenger: controller.binaryMessenger)
        batteryLevelChannel.setStreamHandler(BatteryLevelStreamHandler())
        

        let batteryStateChannel = FlutterEventChannel(name: "battery_state_channel", binaryMessenger: controller.binaryMessenger)
        batteryStateChannel.setStreamHandler(BatteryStateStreamHandler())

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getBatteryLevel() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }

    private func getBatteryState() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
          case .charging:
              return "charging"
          case .full:
              return "full"
          case .unplugged:
              return "unplugged"
          default:
              return "unknown"
        }
    }
}

class BatteryLevelStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let device = UIDevice.current

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        device.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        batteryLevelDidChange()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        eventSink = nil
        return nil
    }

    @objc private func batteryLevelDidChange() {
        eventSink?(Int(device.batteryLevel * 100))
    }
}

class BatteryStateStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let device = UIDevice.current

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        device.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        batteryStateDidChange()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        eventSink = nil
        return nil
    }

    @objc private func batteryStateDidChange() {
        switch device.batteryState {
        case .charging:
            eventSink?("charging")
        case .full:
            eventSink?("full")
        case .unplugged:
            eventSink?("unplugged")
        default:
            eventSink?("unknown")
        }
    }
}
