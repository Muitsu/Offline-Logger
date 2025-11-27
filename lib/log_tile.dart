import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/log_data.dart';

class LogTile extends StatelessWidget {
  final LogData data;
  const LogTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data.level} - ${data.method}",
              style: TextStyle(color: data.getStatusColor()),
            ),
            SizedBox(height: 8),
            Text("Message:"),
            SelectableText(data.message),
            SizedBox(height: 10),
            Text(
              data.date.toString(),
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
