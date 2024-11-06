import 'package:flutter/services.dart';

enum BatteryState {
  unknown._('unknown'),
  charging._('charging'),
  discharging._('discharging'),
  notCharging._('not_charging'),
  full._('full'),
  unplugged._('unplugged');

  final String value;
  const BatteryState._(this.value);

  String get status {
    return "${value[0].toUpperCase()}${value.substring(1)}";
  }

  static BatteryState fromString(String state) {
    switch (state) {
      case 'charging':
        return BatteryState.charging;
      case 'discharging':
        return BatteryState.discharging;
      case 'full':
        return BatteryState.full;
      case 'not_charging':
        return BatteryState.notCharging;
      case 'unplugged':
        return BatteryState.unplugged;
      default:
        return BatteryState.unknown;
    }
  }
}

class BatteryService {
  static const MethodChannel _channel = MethodChannel('battery_channel');
  static const EventChannel _levelChannel = EventChannel('battery_level_channel');
  static const EventChannel _stateChannel = EventChannel('battery_state_channel');

  // Stream for battery level
  static Stream<int> get batteryLevelStream => _levelChannel.receiveBroadcastStream().cast<int>();

  // Stream for battery state
  static Stream<BatteryState> get batteryStateStream => _stateChannel.receiveBroadcastStream().map((event) => BatteryState.fromString(event));

  // Get initial battery level
  static Future<int> getBatteryLevel() async {
    final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
    return batteryLevel;
  }

  // Get initial battery state
  static Future<BatteryState> getBatteryState() async {
    final String batteryState = await _channel.invokeMethod('getBatteryState');
    return BatteryState.fromString(batteryState);
  }
}
