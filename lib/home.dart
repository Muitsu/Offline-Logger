import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/app_logger.dart';
import 'package:offline_logs/create_log_dialog.dart';
import 'package:offline_logs/home_tile.dart';
import 'package:offline_logs/modal_sheet_view.dart';
import 'package:offline_logs/read_log_sheet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int totalLogFiles = 0;
  @override
  void initState() {
    super.initState();
    getTotal();
  }

  void getTotal() async {
    totalLogFiles = await AppLogger().getTotalLogFiles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bug_report),
            SizedBox(width: 6),
            Text(widget.title),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text("Basic Usage"),
            ),
            HomeTile(
              leading: Icon(Icons.edit_note),
              title: "Create Log",
              subtitle: "Create test log",
              onTap: () {
                showCreateLog();
              },
            ),
            HomeTile(
              leading: Icon(Icons.folder),
              title: "Open Log File",
              subtitle: "Latest Log (Externally)",
              onTap: () async => await AppLogger().openLogExternally(),
            ),
            HomeTile(
              leading: Icon(Icons.description),
              title: "Read Log",
              subtitle: "Read Latest Log (In App)",
              onTap: () => readLog(),
            ),
            HomeTile(
              leading: Icon(Icons.share),
              title: "Share Log File",
              subtitle: "Latest Log (Externally)",
              onTap: () async => await AppLogger().shareLogs(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text("Advance Usage"),
            ),
            HomeTile(
              leading: Icon(Icons.folder_copy_rounded),
              title: "View All Log",
              subtitle: "Total Log File : $totalLogFiles",
              onTap: viewAllLog,
            ),
            HomeTile(
              leading: Icon(Icons.delete),
              title: "Clear Log",
              subtitle: "Total Log File : $totalLogFiles",
              onTap: () async {
                await AppLogger().clearLogFiles();
                getTotal();
              },
            ),
          ],
        ),
      ),
    );
  }

  final textCtrl = TextEditingController();
  String selectedData = "Debug";
  void showCreateLog() async {
    textCtrl.clear();
    await showDialog(
      context: context,
      builder: (context) =>
          CreateLogDialog(controller: textCtrl, selectedData: selectedData),
    );
    getTotal();
  }

  void readLog({String? path}) async {
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF2F3136),
      clipBehavior: Clip.antiAlias,
      builder: (_) => ReadLogSheet(path: path),
    );
  }

  void viewAllLog() async {
    final logData = await AppLogger().getAllLogFilePath();
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF2F3136),
      clipBehavior: Clip.antiAlias,
      builder: (_) => ModalSheetView(
        title: "All Logs",
        child: ListView.separated(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(12),
          itemCount: logData.length,
          itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.description),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  logData[index].lastAccessedSync().toString().split(" ")[0],
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
            subtitle: Text(
              logData[index].path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            onTap: () async => readLog(path: logData[index].path),
          ),
          separatorBuilder: (context, index) =>
              Divider(height: 0, color: Colors.white10),
        ),
      ),
    );
  }
}
