import 'package:flutter/material.dart';
import 'package:native_code/screens/device_info_screen.dart';

import 'battery_screen.dart';
import 'network_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Main Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryScreen(title: "Battery Status")));
                  },
                  icon: const Icon(Icons.battery_saver),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NetworkScreen()));
                  },
                  icon: const Icon(Icons.network_check),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DeviceInfoScreen()));
                  },
                  icon: const Icon(Icons.perm_device_info_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
