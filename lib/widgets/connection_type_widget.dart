import 'package:flutter/material.dart';

import '../services/network_service.dart';

class ConnectionTypeWidget extends StatelessWidget {
  const ConnectionTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: NetworkService.connectionTypeStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", textAlign: TextAlign.center);
        }

        final connectionType = snapshot.data ?? "Unknown";

        return RichText(
          text: TextSpan(
            text: "(",
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              WidgetSpan(
                child: Icon(
                  _getConnectionTypeIcon(connectionType),
                  color: _getConnectionTypeColor(connectionType),
                  size: 16,
                ),
              ),
              const TextSpan(
                text: ")",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getConnectionTypeIcon(String type) {
    switch (type) {
      case "WiFi":
        return Icons.wifi;
      case "Cellular":
        return Icons.sim_card;
      default:
        return Icons.signal_cellular_no_sim;
    }
  }

  Color _getConnectionTypeColor(String type) {
    switch (type) {
      case "WiFi":
        return Colors.green;
      case "Cellular":
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
}
