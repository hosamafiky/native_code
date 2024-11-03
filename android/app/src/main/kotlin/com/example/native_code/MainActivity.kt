package com.example.native_code

import android.content.*
import android.os.BatteryManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.example.native_code"
  private val BATTERY_STATE_CHANNEL = "com.example.native_code/batteryState"
  private val BATTERY_LEVEL_CHANNEL = "com.example.native_code/batteryLevel"
  private var batteryLevelStreamHandler: BatteryLevelStreamHandler? = null
  private var batteryStateStreamHandler: BatteryStateStreamHandler? = null

  override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        batteryLevelStreamHandler = BatteryLevelStreamHandler(applicationContext)
        batteryStateStreamHandler = BatteryStateStreamHandler(applicationContext)
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, BATTERY_LEVEL_CHANNEL)
            .setStreamHandler(batteryLevelStreamHandler)
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, BATTERY_STATE_CHANNEL)
            .setStreamHandler(batteryStateStreamHandler)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        batteryLevelStreamHandler?.unregisterReceiver()
        batteryStateStreamHandler?.unregisterReceiver()
    }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
        else -> result.notImplemented()
      }
    }
  }
}

enum class BatteryState(val value: Int) {
    UNKNOWN(BatteryManager.BATTERY_STATUS_UNKNOWN),
    CHARGING(BatteryManager.BATTERY_STATUS_CHARGING),
    DISCHARGING(BatteryManager.BATTERY_STATUS_DISCHARGING),
    NOT_CHARGING(BatteryManager.BATTERY_STATUS_NOT_CHARGING),
    FULL(BatteryManager.BATTERY_STATUS_FULL);

    companion object {
        fun fromInt(value: Int): BatteryState {
          val status = values().firstOrNull { it.value == value } ?: UNKNOWN;
          return status
        }
    }
}


class BatteryLevelStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val batteryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            
            val batteryLevel = if (scale > 0) level * 100.0 / scale else -1.0

            eventSink?.success(batteryLevel)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(batteryReceiver, intentFilter)
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(batteryReceiver)
        eventSink = null
    }

    fun unregisterReceiver() {
        context.unregisterReceiver(batteryReceiver)
    }
}

class BatteryStateStreamHandler(private val context: Context) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val batteryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
            val batteryState = BatteryState.fromInt(status)
            eventSink?.success(batteryState.name)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(batteryReceiver, intentFilter)
    }

    override fun onCancel(arguments: Any?) {
        context.unregisterReceiver(batteryReceiver)
        eventSink = null
    }

    fun unregisterReceiver() {
        context.unregisterReceiver(batteryReceiver)
    }
}