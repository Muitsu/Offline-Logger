import 'package:flutter/material.dart';
import 'package:offline_logs/app-log/app_logger.dart';
import 'package:offline_logs/app-log/log_data.dart';
import 'package:offline_logs/filter_modal.dart';
import 'package:offline_logs/filter_tile.dart';
import 'package:offline_logs/log_tile.dart';
import 'package:offline_logs/modal_sheet_view.dart';
import 'package:flutter/cupertino.dart';

enum ViewMode {
  clean,
  raw;

  const ViewMode();
  static Map<ViewMode, Widget> getMap() => {
    ViewMode.clean: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text('Clean'),
    ),
    ViewMode.raw: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text('Raw'),
    ),
  };
}

class ReadLogSheet extends StatefulWidget {
  final String? path;
  const ReadLogSheet({super.key, this.path});

  @override
  State<ReadLogSheet> createState() => _ReadLogSheetState();
}

class _ReadLogSheetState extends State<ReadLogSheet> {
  ViewMode selected = ViewMode.clean;
  late AppLogFilter selectedFilter;
  @override
  void initState() {
    super.initState();
    selectedFilter = AppLogFilter.all;
    getData();
  }

  List<LogData> cleanData = [];
  List<Widget> cleanWidget = [];
  List<Widget> showWidget = [];
  String rawData = "";

  void getData() async {
    cleanData = await AppLogger().readLogAsObject(customPpath: widget.path);
    rawData = await AppLogger().readLogAsString(customPpath: widget.path);
    cleanWidget = List.generate(cleanData.length, (index) {
      final data = cleanData[index];
      return LogTile(data: data);
    });
    filterData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetView(
      title: "Audit Log",
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: CupertinoSlidingSegmentedControl<ViewMode>(
          groupValue: selected,
          children: ViewMode.getMap(),
          onValueChanged: (newValue) {
            if (newValue != null) {
              setState(() => selected = newValue);
            }
          },
        ),
      ),
      child: selected == ViewMode.raw
          ? ListView(
              padding: EdgeInsets.all(12),
              children: [SelectableText(rawData)],
            )
          : Column(
              children: [
                FilterTile(
                  selectedFilter: selectedFilter,
                  onTap: openFilterModal,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    physics: BouncingScrollPhysics(),
                    itemCount: showWidget.length,
                    itemBuilder: (context, index) => showWidget[index],
                  ),
                ),
              ],
            ),
    );
  }

  void openFilterModal() async {
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF2F3136),
      clipBehavior: Clip.antiAlias,
      builder: (_) => FilterModal(
        groupValue: selectedFilter,
        onChanged: (val) {
          Navigator.pop(context);
          if (val != null) {
            selectedFilter = val;
            filterData();
          }
        },
      ),
    );
  }

  void filterData() {
    if (selectedFilter == AppLogFilter.all) {
      showWidget = List<Widget>.of(cleanWidget);
      setState(() {});
      return;
    }
    final copyData = List<LogData>.from(cleanData);
    final filtered = copyData
        .where(
          (element) =>
              AppLogFilter.getLogByString(element.level) == selectedFilter,
        )
        .toList();
    showWidget = List.generate(filtered.length, (index) {
      final data = filtered[index];
      return LogTile(data: data);
    });

    setState(() {});
  }
}
