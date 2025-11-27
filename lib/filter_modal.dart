import 'package:flutter/material.dart';
import 'package:offline_logs/filter_tile.dart';

class FilterModal extends StatelessWidget {
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final void Function(AppLogFilter?) onChanged;
  final AppLogFilter? groupValue;
  const FilterModal({
    super.key,
    this.actions,
    this.bottom,
    required this.onChanged,
    this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 30,
              height: 4,
              margin: EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          RadioGroup<AppLogFilter>(
            groupValue: groupValue ?? AppLogFilter.all,
            onChanged: onChanged,
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Scrollbar(
                radius: Radius.circular(16),
                child: ListView.separated(
                  itemCount: AppLogFilter.values.length,
                  itemBuilder: (context, index) {
                    final item = AppLogFilter.values[index];
                    return RadioListTile<AppLogFilter>(
                      fillColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Color(0xFF5336ff);
                        }
                        return Colors.white30;
                      }),
                      title: Text(
                        item.displayName,
                        style: TextStyle(
                          color: item.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: item,
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 0,
                    indent: 40,
                    color: Colors.white10.withValues(alpha: .05),
                  ),
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
