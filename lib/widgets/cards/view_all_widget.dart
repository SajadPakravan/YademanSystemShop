import 'package:flutter/material.dart';

class ViewAllWidget extends StatelessWidget {
  const ViewAllWidget({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xff0b74d5), Color(0xff034b91)]),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 31),
                ),
                const SizedBox(height: 18),
                Text(
                  title.isEmpty ? 'مشاهده همه' : title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xff034b91), fontSize: 15, fontWeight: FontWeight.w800, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
