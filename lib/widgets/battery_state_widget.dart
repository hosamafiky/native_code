import 'package:flutter/material.dart';
import 'package:native_code/helper/native_communicate_helper.dart';

import 'battery_level_indicator.dart';

class BatteryStateWidget extends StatelessWidget {
  final Stream<BatteryState> batteryStateStream;

  const BatteryStateWidget({super.key, required this.batteryStateStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BatteryState>(
      stream: batteryStateStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Text("Loading battery status...", textAlign: TextAlign.center);
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", textAlign: TextAlign.center);
        }

        final batteryState = snapshot.data ?? BatteryState.unknown;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getBatteryIcon(batteryState),
              color: _getBatteryColor(batteryState),
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              batteryState.status,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            if (batteryState == BatteryState.charging || batteryState == BatteryState.discharging) ...[
              const SizedBox(width: 8),
              BatteryLevelIndicator(batteryLevelStream: BatteryService.batteryLevelStream),
            ] else ...[
              BatteryLevelIndicator.text(batteryLevelStream: BatteryService.batteryLevelStream)
            ],
          ],
        );
      },
    );
  }

  IconData _getBatteryIcon(BatteryState state) {
    switch (state.value) {
      case "charging":
        return Icons.battery_charging_full_outlined;
      case "not_charging":
        return Icons.battery_alert_outlined;
      case "unplugged":
      case "discharging":
        return Icons.battery_std_outlined;
      case "full":
        return Icons.battery_full_outlined;
      default:
        return Icons.battery_unknown_outlined;
    }
  }

  Color _getBatteryColor(BatteryState state) {
    switch (state.value) {
      case "charging":
      case "full":
        return Colors.green;
      case "discharging":
        return Colors.orange;
      case "not_charging":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
