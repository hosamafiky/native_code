import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let batteryLevelChannel = "com.example.native_code/levelStream"
  private var eventSink: FlutterEventSink?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "com.example.native_code", binaryMessenger: controller.binaryMessenger)
    let batteryEventChannel = FlutterEventChannel(name: batteryLevelChannel, binaryMessenger: controller.binaryMessenger)
    batteryEventChannel.setStreamHandler(self)
    UIDevice.current.isBatteryMonitoringEnabled = true  
    methodChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if call.method == "getIOSVersion" {
        self?.getIOSVersion(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    UIDevice.current.isBatteryMonitoringEnabled = false
  }

  private func getIOSVersion(result: FlutterResult) {
    if let systemVersion = Double(UIDevice.current.systemVersion) {
      result(systemVersion)
    } else {
      result(FlutterError(code: "UNAVAILABLE", message: "iOS version is not available", details: nil))
    }
  }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryStatusDidChange),
      name: UIDevice.batteryLevelDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(batteryStatusDidChange),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil
    )
    sendBatteryStatus() // Send initial battery status
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    eventSink = nil
    return nil
  }
  
  @objc private func batteryStatusDidChange() {
    sendBatteryStatus()
  }
  
  private func sendBatteryStatus() {
    let batteryLevel = UIDevice.current.batteryLevel
    let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
    
    if batteryLevel >= 0 {
      eventSink?(["batteryLevel": Double(batteryLevel * 100), "isCharging": isCharging])
    } else {
      eventSink?(FlutterError(code: "UNAVAILABLE", message: "Battery level unavailable", details: nil))
    }
  }
}