import 'package:flutter/material.dart';
import 'package:offline_logs/app_logger.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await AppLogger().shareLogs();
            },
            icon: Icon(Icons.share),
          ),
          ActionChip(
            label: Text("Open Log"),
            onPressed: () async => await AppLogger().openLogExternally(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                AppLogger().debug("Button 1", "Test Debug");
              },
              child: Text("Log Debug"),
            ),
            ElevatedButton(
              onPressed: () {
                AppLogger().debug("Button 2", "Test Warning");
              },
              child: Text("Log Warning"),
            ),
            ElevatedButton(
              onPressed: () {
                AppLogger().debug("Button 3", "Test Error");
              },
              child: Text("Log Error"),
            ),
            ElevatedButton(
              onPressed: () async {
                await AppLogger().clearLogFiles();
                getTotal();
              },
              child: Text("Clear Log File $totalLogFiles"),
            ),
          ],
        ),
      ),
    );
  }
}
