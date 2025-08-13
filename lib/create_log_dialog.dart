import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/app_logger.dart';
import 'package:offline_logs/chip_dropdown.dart';

class CreateLogDialog extends StatefulWidget {
  final TextEditingController controller;
  final String selectedData;
  const CreateLogDialog({
    super.key,
    required this.controller,
    required this.selectedData,
  });

  @override
  State<CreateLogDialog> createState() => _CreateLogDialogState();
}

class _CreateLogDialogState extends State<CreateLogDialog> {
  String selectedType = "";

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedData;
  }

  @override
  Widget build(BuildContext context) {
    final mapData = ["Debug", "Warning", "Error"];
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      backgroundColor: Color(0xFF2F3136),
      insetPadding: EdgeInsets.all(20),
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("App Logger"),
                ChipDropdown<String>(
                  items: mapData,
                  labelBuilder: (label) => label,
                  initialValue: selectedType,
                  onChanged: (type) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              controller: widget.controller,
              maxLines: 4,
              decoration: InputDecoration(
                hint: Text("Enter Log"),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  String msg = widget.controller.text.isEmpty
                      ? "Test Log"
                      : widget.controller.text;

                  Navigator.pop(context);

                  if (selectedType == "Debug") {
                    await AppLogger().debug(
                      "Send Log",
                      msg: msg,
                      saveLog: true,
                    );
                  } else if (selectedType == "Warning") {
                    await AppLogger().warning(
                      "Send Log",
                      msg: msg,
                      saveLog: true,
                    );
                  } else {
                    await AppLogger().error(
                      "Send Log",
                      msg: msg,
                      saveLog: true,
                    );
                  }
                },
                child: Text("Send Log"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
