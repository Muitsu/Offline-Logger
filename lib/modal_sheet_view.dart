import 'package:flutter/material.dart';

class ModalSheetView extends StatelessWidget {
  final String title;

  final List<Widget> children;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  const ModalSheetView({
    super.key,
    required this.children,
    this.actions,
    required this.title,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .8,
      width: MediaQuery.sizeOf(context).width,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          scrolledUnderElevation: 0,
          actions: actions,
          bottom: bottom,
        ),
        backgroundColor: Color(0xFF2F3136),
        body: Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Scrollbar(
            radius: Radius.circular(16),
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(12),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
