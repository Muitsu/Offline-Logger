import 'package:flutter/material.dart';

enum AppLogFilter {
  all(displayName: "All Logs", color: Colors.white70),
  info(displayName: "Info Only", color: Color.fromARGB(255, 48, 99, 189)),
  warning(
    displayName: "Warning Only",
    color: Color.fromARGB(255, 156, 121, 16),
  ),
  error(displayName: "Error Only", color: Color.fromARGB(255, 180, 44, 34));

  const AppLogFilter({required this.displayName, required this.color});
  final String displayName;
  final Color color;

  static AppLogFilter getLogByName(AppLogFilter filter) {
    return AppLogFilter.values.firstWhere(
      (element) => element == filter,
      orElse: () => AppLogFilter.all,
    );
  }

  static AppLogFilter getLogByString(String filter) {
    return AppLogFilter.values.firstWhere(
      (element) =>
          element.displayName.toLowerCase().contains(filter.toLowerCase()),
      orElse: () => AppLogFilter.all,
    );
  }
}

class FilterTile extends StatelessWidget {
  final Widget? subtitle;
  final Widget? leading;
  final AppLogFilter selectedFilter;
  final void Function()? onTap;
  const FilterTile({
    super.key,
    this.subtitle,
    this.leading,
    this.onTap,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        leading: Text(
          "Logs Filter  ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF202225),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppLogFilter.getLogByName(selectedFilter).color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    selectedFilter.displayName,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: subtitle,

        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
        tileColor: Colors.white.withValues(alpha: .05),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(14),
        ),
      ),
    );
  }
}
