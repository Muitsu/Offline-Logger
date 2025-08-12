import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/app_logger.dart';
import 'package:offline_logs/app-log/log_data.dart';
import 'package:offline_logs/modal_sheet_view.dart';

enum ViewMode { clean, raw }

class ReadLogSheet extends StatefulWidget {
  final String? path;
  const ReadLogSheet({super.key, this.path});

  @override
  State<ReadLogSheet> createState() => _ReadLogSheetState();
}

class _ReadLogSheetState extends State<ReadLogSheet> {
  ViewMode selected = ViewMode.clean;
  @override
  void initState() {
    super.initState();
    getData();
  }

  List<LogData> cleanData = [];
  List<Widget> cleanWidget = [];
  String rawData = "";

  void getData() async {
    cleanData = await AppLogger().readLogAsObject(customPpath: widget.path);
    rawData = await AppLogger().readLogAsString(customPpath: widget.path);
    cleanWidget = List.generate(cleanData.length, (index) {
      final data = cleanData[index];

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${data.level} - ${data.method}"),
              SizedBox(height: 8),
              Text("Message:"),
              Text(data.message),
              SizedBox(height: 8),
              Text(data.date.toString()),
            ],
          ),
        ),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetView(
      title: "Read Log",
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: SegmentedButton<ViewMode>(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black54;
              }
              return Colors.white10;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return Colors.white;
            }),
            side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
              if (states.contains(WidgetState.selected)) {
                return const BorderSide(color: Colors.blue, width: 2);
              }
              return const BorderSide(color: Colors.grey, width: 1);
            }),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          segments: const <ButtonSegment<ViewMode>>[
            ButtonSegment<ViewMode>(
              value: ViewMode.clean,
              label: Text('Clean'),
              icon: Icon(Icons.star),
            ),
            ButtonSegment<ViewMode>(
              value: ViewMode.raw,
              label: Text('Raw'),
              icon: Icon(Icons.code),
            ),
          ],
          selected: <ViewMode>{selected},
          onSelectionChanged: (Set<ViewMode> newSelection) {
            setState(() => selected = newSelection.first);
          },
        ),
      ),
      children: selected == ViewMode.raw ? [Text(rawData)] : cleanWidget,
    );
  }
}
