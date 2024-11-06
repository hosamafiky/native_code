import 'dart:async';

import 'package:flutter/services.dart';

class NetworkService {
  static const MethodChannel _channel = MethodChannel('network_channel');
  static const EventChannel _connectivityChannel = EventChannel('network_connectivity_channel');
  static const EventChannel _connectionTypeChannel = EventChannel('network_type_channel');

  // Stream for connectivity status (isConnected)
  static Stream<bool> get isConnectedStream => _connectivityChannel.receiveBroadcastStream().cast<bool>();

  // Stream for connection type (e.g., WiFi, Mobile)
  static Stream<String> get connectionTypeStream => _connectionTypeChannel.receiveBroadcastStream().cast<String>();

  // Get initial connectivity status
  static Future<bool> getInitialConnectivity() async {
    return await _channel.invokeMethod('getInitialConnectivity');
  }

  // Get initial connection type
  static Future<String> getInitialConnectionType() async {
    return await _channel.invokeMethod('getInitialConnectionType');
  }
}
