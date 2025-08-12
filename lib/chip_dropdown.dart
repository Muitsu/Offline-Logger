import 'package:flutter/material.dart';

class ChipDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T>? onChanged;
  final String Function(T) labelBuilder;

  const ChipDropdown({
    super.key,
    required this.items,
    required this.labelBuilder,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<ChipDropdown<T>> createState() => _ChipDropdownState<T>();
}

class _ChipDropdownState<T> extends State<ChipDropdown<T>> {
  late T selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ?? widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: selectedValue,
        icon: SizedBox(),
        dropdownColor: Colors.black, // Discord dark panel
        iconEnabledColor: Colors.white70,
        items: widget.items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Chip(
              color: WidgetStateColor.resolveWith((state) => Colors.black26),
              shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
              label: Row(
                children: [
                  Text(
                    widget.labelBuilder(item),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedValue = value;
            });
            widget.onChanged?.call(value);
          }
        },
      ),
    );
  }
}
