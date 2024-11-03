import 'package:flutter/services.dart';

enum BatteryState {
  unknown._('UNKNOWN'),
  charging._('CHARGING'),
  discharging._('DISCHARGING'),
  notCharging._('NOT_CHARGING'),
  full._('FULL');

  final String value;
  const BatteryState._(this.value);

  static BatteryState fromString(String state) {
    return BatteryState.values.firstWhere((e) => e.value == state, orElse: () => BatteryState.unknown);
  }
}

class NativeCommunicateHelper {
  static const MethodChannel _methodChannel = MethodChannel('com.example.native_code');
  static const EventChannel _batteryStateChannel = EventChannel('com.example.native_code/batteryState');
  static const EventChannel _batteryLevelChannel = EventChannel('com.example.native_code/batteryLevel');

  static Future<String> getPlatformVersion() async {
    try {
      return await _methodChannel.invokeMethod('getPlatformVersion');
    } on PlatformException catch (e) {
      throw Exception('Failed to get platform version: ${e.message}');
    }
  }

  static Future<double> getIOSVersion() async {
    try {
      return await _methodChannel.invokeMethod('getIOSVersion');
    } on PlatformException catch (e) {
      throw Exception('Failed to get iOS version: ${e.message}');
    }
  }

  static Stream<BatteryState> get batteryState {
    return _batteryStateChannel.receiveBroadcastStream().map((event) => BatteryState.fromString(event));
  }

  static Stream<double> get batteryLevel {
    return _batteryLevelChannel.receiveBroadcastStream().map((event) => event as double);
  }
}
