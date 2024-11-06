import 'package:flutter/material.dart';

class BatteryLevelIndicator extends StatelessWidget {
  const BatteryLevelIndicator({super.key, required this.batteryLevelStream}) : _isText = false;

  const BatteryLevelIndicator.text({super.key, required this.batteryLevelStream}) : _isText = true;

  final bool _isText;
  final Stream<int> batteryLevelStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: batteryLevelStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            strokeCap: StrokeCap.round,
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        } else if (snapshot.hasData) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (!_isText)
                CircularProgressIndicator(
                  value: snapshot.data! / 100,
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  strokeCap: StrokeCap.round,
                ),
              Center(
                child: Text(
                  _isText ? '(${snapshot.data}%)' : '${snapshot.data}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Text('Battery Level: Unknown', textAlign: TextAlign.center);
        }
      },
    );
  }
}
