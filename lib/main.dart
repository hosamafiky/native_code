import 'dart:io';

import 'package:flutter/material.dart';

import 'helper/native_communicate_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  double _iosVersion = 1.0;

  void getPlatformVersion() async {
    final String platformVersion = await NativeCommunicateHelper.getPlatformVersion();
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void getIOSVersion() async {
    final double iosVersion = await NativeCommunicateHelper.getIOSVersion();
    setState(() {
      _iosVersion = iosVersion;
    });
  }

  @override
  void initState() {
    if (Platform.isIOS) {
      getIOSVersion();
    } else {
      getPlatformVersion();
    }
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
            Text(
              'Running on: ${Platform.isAndroid ? _platformVersion : 'iOS $_iosVersion'}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            StreamBuilder<double>(
              stream: NativeCommunicateHelper.batteryLevel,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text('Battery Level: ${snapshot.data}%');
                } else {
                  return const Text('Battery Level: Unknown');
                }
              },
            ),
            StreamBuilder<BatteryState>(
              stream: NativeCommunicateHelper.batteryState,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Column(
                    children: BatteryState.values.map((state) {
                      return CheckboxListTile.adaptive(
                        value: state == snapshot.data,
                        onChanged: (_) {},
                        title: Text(state.value),
                      );
                    }).toList(),
                  );
                } else {
                  return const Text('Battery Level: Unknown');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
