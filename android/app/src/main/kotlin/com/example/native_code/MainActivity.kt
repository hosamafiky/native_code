package com.example.native_code

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine


class MainActivity: FlutterActivity() {
    private val batteryChannel = "battery_channel"
    private val batteryLevelChannel = "battery_level_channel"
    private val batteryStateChannel = "battery_state_channel"
    private val networkChannel = "network_channel"
    private val connectivityChannel = "network_connectivity_channel"
    private val connectionTypeChannel = "network_type_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, batteryChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> result.success(getBatteryLevel())
                "getBatteryState" -> result.success(getBatteryState())
                "getInitialConnectivity" -> result.success(isConnected())
                "getInitialConnectionType" -> result.success(getConnectionType())
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, batteryLevelChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var levelReceiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    levelReceiver = createBatteryLevelReceiver(events)
                    registerReceiver(levelReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(levelReceiver)
                    levelReceiver = null
                }
            }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, batteryStateChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var stateReceiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    stateReceiver = createBatteryStateReceiver(events)
                    registerReceiver(stateReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(stateReceiver)
                    stateReceiver = null
                }
            }
        )
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, connectivityChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var connectivityReceiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    connectivityReceiver = createConnectivityReceiver(events)
                    registerReceiver(connectivityReceiver, IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(connectivityReceiver)
                    connectivityReceiver = null
                }
            }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, connectionTypeChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var connectionTypeReceiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    connectionTypeReceiver = createConnectionTypeReceiver(events)
                    registerReceiver(connectionTypeReceiver, IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(connectionTypeReceiver)
                    connectionTypeReceiver = null
                }
            }
        )
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun getBatteryState(): String {
        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
            BatteryManager.BATTERY_STATUS_FULL -> "full"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "not_charging"
            else -> "unknown"
        }
    }

    private fun createBatteryLevelReceiver(events: EventChannel.EventSink?) = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            events?.success(level)
        }
    }

    private fun createBatteryStateReceiver(events: EventChannel.EventSink?) = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
            val state = when (status) {
                BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
                BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
                BatteryManager.BATTERY_STATUS_FULL -> "full"
                BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "not_charging"
                else -> "unknown"
            }
            events?.success(state)
        }
    }

    private fun isConnected(): Boolean {
        val connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork = connectivityManager.activeNetwork
        return activeNetwork != null
    }

    private fun getConnectionType(): String {
        val connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
        return when {
            capabilities == null -> "none"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "WiFi"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Cellular"
            else -> "Unknown"
        }
    }

    private fun createConnectivityReceiver(events: EventChannel.EventSink?) = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            events?.success(isConnected())
        }
    }

    private fun createConnectionTypeReceiver(events: EventChannel.EventSink?) = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            events?.success(getConnectionType())
        }
    }
}
