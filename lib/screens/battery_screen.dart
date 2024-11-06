import 'package:flutter/material.dart';
import 'package:native_code/widgets/battery_state_widget.dart';

import '../helper/native_communicate_helper.dart';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key, required this.title});

  final String title;

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  // String _platformVersion = 'Unknown';
  // double _iosVersion = 1.0;

  // void getPlatformVersion() async {
  //   final String platformVersion = await NativeCommunicateHelper.getPlatformVersion();
  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  // void getIOSVersion() async {
  //   final double iosVersion = await NativeCommunicateHelper.getIOSVersion();
  //   setState(() {
  //     _iosVersion = iosVersion;
  //   });
  // }

  @override
  void initState() {
    // if (Platform.isIOS) {
    //   getIOSVersion();
    // } else {
    //   getPlatformVersion();
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'Running on: ${Platform.isAndroid ? _platformVersion : 'iOS $_iosVersion'}',
            //   textAlign: TextAlign.center,
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            // const SizedBox(height: 20),

            BatteryStateWidget(batteryStateStream: BatteryService.batteryStateStream),
          ],
        ),
      ),
    );
  }
}
