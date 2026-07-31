import 'package:flutter/material.dart';

class ViewAllWidget extends StatelessWidget {
  const ViewAllWidget({super.key, required this.title, required this.onTap, this.foregroundColor = Colors.blue});

  final String title;
  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foregroundColor.withAlpha(50),
            ),
            child: Icon(Icons.arrow_forward_rounded, color: foregroundColor, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            title.isEmpty ? 'مشاهده همه' : title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foregroundColor, fontSize: 15, fontWeight: FontWeight.w800, height: 1.5),
          ),
        ],
      ),
    );
  }
}
