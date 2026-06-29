import 'package:flutter/material.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
      child: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeMenuItem(icon: Icons.info_outline, title: 'درباره ما', url: 'https://yademansystem.ir/about-us/'),
              HomeMenuItem(icon: Icons.phone, title: 'تماس باما', url: 'https://yademansystem.ir/contact-us/'),
              HomeMenuItem(icon: Icons.question_mark_rounded, title: 'مجله یادمان ‌سیستم', url: 'https://yademansystem.ir/journal/'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeMenuItem(icon: Icons.question_mark_rounded, title: 'پرسش‌های متداول', url: 'https://yademansystem.ir/questions/'),
              HomeMenuItem(icon: Icons.headset_mic, title: 'مشاوره خرید', url: 'https://yademansystem.ir/buy-advisor/'),
              HomeMenuItem(icon: Icons.question_mark_rounded, title: 'ثبت سفارش ویژه', url: 'https://yademansystem.ir/place-order/'),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeMenuItem extends StatefulWidget {
  const HomeMenuItem({super.key, required this.title, required this.icon, required this.url});

  final String title;
  final IconData icon;
  final String url;

  @override
  State<HomeMenuItem> createState() => _HomeMenuItemState();
}

class _HomeMenuItemState extends State<HomeMenuItem> {
  bool _isTapped = false;

  void _handleTap() {
    setState(() => _isTapped = true);
    Future.delayed(const Duration(milliseconds: 100), () => setState(() => _isTapped = false));
    zoomToPage(WebScreen(url: widget.url, title: widget.title));
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: _handleTap,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _isTapped ? Colors.black26 : const Color(0xff0353a4),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 35),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: TextBodyMediumView(widget.title, textAlign: TextAlign.center, maxLines: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
