import Flutter
import UIKit
import Network

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue.global(qos: .background)
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
        let networkChannel = FlutterMethodChannel(name: "network_channel", binaryMessenger: controller.binaryMessenger)
        networkChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "getInitialConnectivity":
                result(self.isConnected())
            case "getInitialConnectionType":
                result(self.getConnectionType())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Initialize and start monitoring
        startNetworkMonitoring()

        let batteryLevelChannel = FlutterEventChannel(name: "battery_level_channel", binaryMessenger: controller.binaryMessenger)
        batteryLevelChannel.setStreamHandler(BatteryLevelStreamHandler())
        

        let batteryStateChannel = FlutterEventChannel(name: "battery_state_channel", binaryMessenger: controller.binaryMessenger)
        batteryStateChannel.setStreamHandler(BatteryStateStreamHandler())

        // Set up event channels for connectivity and connection type
        let connectivityChannel = FlutterEventChannel(name: "network_connectivity_channel", binaryMessenger: controller.binaryMessenger)
        connectivityChannel.setStreamHandler(NetworkConnectivityStreamHandler(monitor: monitor))

        let connectionTypeChannel = FlutterEventChannel(name: "network_type_channel", binaryMessenger: controller.binaryMessenger)
        connectionTypeChannel.setStreamHandler(NetworkTypeStreamHandler(monitor: monitor))

        

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
    private func startNetworkMonitoring() {
        monitor = NWPathMonitor()
        monitor?.start(queue: queue)
    }

    private func isConnected() -> Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }

    private func getConnectionType() -> String {
        guard let monitor = monitor else { return "None" }
        switch monitor.currentPath.availableInterfaces.first?.type {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        default:
            return "None"
        }
    }
// Stream handler for connection type (WiFi, Cellular, None)
class NetworkTypeStreamHandler: NSObject, FlutterStreamHandler {
    private var monitor: NWPathMonitor?
    private var eventSink: FlutterEventSink?

    init(monitor: NWPathMonitor?) {
        self.monitor = monitor
        super.init()
        switch monitor?.currentPath.availableInterfaces.first?.type {
            case .wifi:
                self.eventSink?("WiFi")
            case .cellular:
                self.eventSink?("Cellular")
            default:
                self.eventSink?("None")
        }
        monitor?.pathUpdateHandler = { [weak self] path in
            switch path.availableInterfaces.first?.type {
            case .wifi:
                self?.eventSink?("WiFi")
            case .cellular:
                self?.eventSink?("Cellular")
            default:
                self?.eventSink?("None")
            }
            
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        // Emit the current connection type
        switch monitor?.currentPath.availableInterfaces.first?.type {
            case .wifi:
                events("WiFi")
            case .cellular:
                events("Cellular")
            default:
                events("None")
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
    override func applicationWillTerminate(_ application: UIApplication) {
        monitor?.cancel()
    }
}
// Stream handler for connectivity status (isConnected)
class NetworkConnectivityStreamHandler: NSObject, FlutterStreamHandler {
    private var monitor: NWPathMonitor?
    private var eventSink: FlutterEventSink?

    init(monitor: NWPathMonitor?) {
        self.monitor = monitor
        super.init()
        self.eventSink?(monitor?.currentPath.status == .satisfied)
        monitor?.pathUpdateHandler = { [weak self] path in
            self?.eventSink?(path.status == .satisfied)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        // Emit the current connectivity state
        events(monitor?.currentPath.status == .satisfied)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
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

