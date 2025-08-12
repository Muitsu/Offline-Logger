import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final void Function()? onTap;
  const HomeTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        // contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: TextStyle(fontSize: 12)),
        leading: leading,
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
