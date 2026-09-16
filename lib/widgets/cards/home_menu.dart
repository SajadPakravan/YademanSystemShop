import 'package:flutter/material.dart';
import 'package:yad_sys/screens/web_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeMenuItem(icon: Icons.info_outline, title: 'درباره ما', url: 'https://yademansystem.ir/about-us/'),
              HomeMenuItem(icon: Icons.phone, title: 'تماس باما', url: 'https://yademansystem.ir/contact-us/'),
              HomeMenuItem(icon: Icons.menu_book_rounded, title: 'مجله یادمان ‌سیستم', url: 'https://yademansystem.ir/journal/'),
            ],
          ),
          SizedBox(height: r.space(10)),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeMenuItem(icon: Icons.help_outline_rounded, title: 'پرسش‌های متداول', url: 'https://yademansystem.ir/questions/'),
              HomeMenuItem(icon: Icons.headset_mic, title: 'مشاوره خرید', url: 'https://yademansystem.ir/buy-advisor/'),
              HomeMenuItem(icon: Icons.receipt_long_outlined, title: 'ثبت سفارش ویژه', url: 'https://yademansystem.ir/place-order/'),
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
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isTapped = false);
    });
    zoomToPage(WebScreen(url: widget.url, title: widget.title));
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(r.cardRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space(4), vertical: r.space(4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.all(r.space(7)),
                decoration: BoxDecoration(
                  color: _isTapped ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(r.radius(11)),
                ),
                child: Icon(widget.icon, color: AppColors.onBrand, size: r.icon(32, min: 28, max: 38)),
              ),
              SizedBox(height: r.space(6)),
              AppText.bodySmall(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
