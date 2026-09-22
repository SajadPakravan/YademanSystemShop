import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProductConsulta extends StatelessWidget {
  const ProductConsulta({super.key, required this.name, required this.image});

  final String name;
  final String image;
  static const String inquiryPhoneNumber = '03142620486';

  static Future<void> show({required BuildContext context, required String name, required String image}) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'استعلام محصول',
      barrierColor: context.appColors.overlay,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => ProductConsulta(name: name, image: image),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween<double>(begin: 0.94, end: 1).animate(curved), child: child),
        );
      },
    );
  }

  Future<void> _callStore(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: inquiryPhoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان باز کردن برنامه تماس وجود ندارد.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 390),
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(r.radius(18)),
                    border: Border.all(color: colors.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 28, offset: const Offset(0, 12))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _header(context),
                      Divider(height: 1, thickness: 1, color: colors.border),
                      Padding(
                        padding: EdgeInsets.fromLTRB(r.space(18), r.space(18), r.space(18), r.space(20)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.bodySmall(
                              'برای استعلام قیمت و موجودی این محصول با فروشگاه تماس بگیرید.',
                              color: colors.textSecondary,
                              textAlign: TextAlign.center,
                              height: 1.8,
                            ),
                            SizedBox(height: r.space(16)),
                            Material(
                              color: colors.inquiryBackground,
                              borderRadius: BorderRadius.circular(r.radius(12)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(r.radius(12)),
                                onTap: () => _callStore(context),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: r.space(14), vertical: r.space(12)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone_rounded, size: r.icon(20), color: colors.inquiryForeground),
                                      SizedBox(width: r.space(8)),
                                      AppText.bodySmall(
                                        inquiryPhoneNumber.toPersianDigit(),
                                        color: colors.inquiryForeground,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        height: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: r.space(8)),
                            AppText.labelSmall('برای تماس روی شماره بزنید', color: colors.textMuted, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.all(r.space(12)),
      child: Column(
        spacing: r.space(10),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.labelMedium('استعلام قیمت و موجودی محصول', color: colors.inquiryForeground, fontWeight: FontWeight.bold),
              IconButton(onPressed: () => Navigator.of(context).pop(), tooltip: 'بستن', icon: const Icon(Icons.close_rounded), color: colors.textSecondary),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(r.radius(10)),
            child: SizedBox(
              width: r.space(150),
              height: r.space(150),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: colors.background,
                  alignment: Alignment.center,
                  child: SizedBox(width: r.icon(20), height: r.icon(20), child: const CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.background,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined, color: colors.textMuted, size: r.icon(28)),
                ),
              ),
            ),
          ),
          AppText.bodySmall(name, maxLines: 2, overflow: TextOverflow.ellipsis, color: colors.textPrimary, fontWeight: FontWeight.bold, height: 1.55),
        ],
      ),
    );
  }
}
