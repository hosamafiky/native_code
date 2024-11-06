import 'package:flutter/material.dart';

import '../services/network_service.dart';
import 'connection_type_widget.dart';

class NetworkStateWidget extends StatelessWidget {
  const NetworkStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService.isConnectedStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Text("Loading network status...", textAlign: TextAlign.center);
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", textAlign: TextAlign.center);
        }

        final isConnected = snapshot.data ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              isConnected ? "Connected" : "Disconnected",
              style: const TextStyle(fontSize: 16),
            ),
            if (isConnected) ...[
              const SizedBox(width: 8),
              const ConnectionTypeWidget(),
            ],
          ],
        );
      },
    );
  }
}
