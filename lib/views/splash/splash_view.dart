import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/splash/splash_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/splash/splash_logo_data.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

final _splashLogoBytes = base64Decode(kYademanSplashLogoBase64);

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SplashViewModel>();
    final r = context.responsive;
    final compact = r.isCompact;
    final logoSize = r.percentWidth(0.58, min: 170, max: 310).clamp(170.0, r.height * 0.31).toDouble();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SplashBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                r.percentWidth(0.07, min: 22, max: 36),
                compact ? r.space(22) : r.space(38),
                r.percentWidth(0.07, min: 22, max: 36),
                compact ? r.space(20) : r.space(30),
              ),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 2),
                  _LogoCard(size: logoSize),
                  SizedBox(height: r.space(compact ? 20 : 26)),
                  AppText.titleLarge(
                    'فروشگاه یادمان سیستم',
                    color: AppColors.onBrand,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.space(8)),
                  AppText.bodyMedium(
                    'فروشگاه تخصصی لپ‌تاپ، کامپیوتر و لوازم جانبی دیجیتال',
                    color: AppColors.onBrand.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w500,
                    height: 1.75,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  _ConnectionCard(state: viewModel.state, onRetry: viewModel.checkConnection),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.28), blurRadius: 36, spreadRadius: 2, offset: const Offset(0, 14)),
          BoxShadow(color: AppColors.splashCircuit.withValues(alpha: 0.12), blurRadius: 48, spreadRadius: 8),
        ],
      ),
      child: Image.memory(_splashLogoBytes, fit: BoxFit.contain),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.state, required this.onRetry});

  final SplashConnectionState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    late final IconData icon;
    late final String title;
    late final String description;
    late final Color iconColor;
    final showRetry = state == SplashConnectionState.offline || state == SplashConnectionState.serverUnavailable;

    switch (state) {
      case SplashConnectionState.checking:
        icon = Icons.sync_rounded;
        title = 'در حال اتصال به فروشگاه';
        description = 'لطفاً چند لحظه صبر کنید...';
        iconColor = AppColors.splashInfo;
        break;
      case SplashConnectionState.offline:
        icon = Icons.wifi_off_rounded;
        title = 'اتصال اینترنت برقرار نیست';
        description = 'اینترنت دستگاه را بررسی کنید و دوباره تلاش کنید';
        iconColor = AppColors.splashWarning;
        break;
      case SplashConnectionState.serverUnavailable:
        icon = Icons.cloud_off_rounded;
        title = 'ارتباط با سرور برقرار نشد';
        description = 'وضعیت اینترنت را بررسی کنید و اگر VPN روشن است آن را خاموش کنید';
        iconColor = AppColors.splashError;
        break;
      case SplashConnectionState.connected:
        icon = Icons.check_circle_rounded;
        title = 'اتصال برقرار شد';
        description = 'در حال ورود به فروشگاه...';
        iconColor = AppColors.splashSuccess;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(13)),
      decoration: BoxDecoration(
        color: AppColors.onBrand.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(r.radius(20)),
        border: Border.all(color: AppColors.onBrand.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: <Widget>[
          if (state == SplashConnectionState.checking)
            SizedBox(
              width: r.icon(28),
              height: r.icon(28),
              child: CircularProgressIndicator(strokeWidth: 2.6, color: iconColor),
            )
          else
            Icon(icon, color: iconColor, size: r.icon(34)),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppText.bodyMedium(
                  title,
                  color: AppColors.onBrand,
                  fontWeight: FontWeight.w800,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: r.space(3)),
                AppText.bodySmall(
                  description,
                  color: AppColors.onBrand.withValues(alpha: 0.80),
                  height: 1.6,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          if (showRetry) ...<Widget>[
            SizedBox(width: r.space(8)),
            AppButton(
              label: 'تلاش دوباره',
              type: AppButtonType.text,
              expand: false,
              foregroundColor: AppColors.onBrand,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[AppColors.splashTop, AppColors.splashMid, AppColors.primary, AppColors.splashBottom],
          stops: <double>[0, 0.36, 0.68, 1],
        ),
      ),
      child: CustomPaint(painter: _TechBackgroundPainter()),
    );
  }
}

class _TechBackgroundPainter extends CustomPainter {
  const _TechBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.onBrand.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const grid = 46.0;
    for (double x = 0; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final circuitPaint = Paint()
      ..color = AppColors.splashCircuit.withValues(alpha: 0.085)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final paths = <Path>[
      Path()
        ..moveTo(0, size.height * 0.24)
        ..lineTo(size.width * 0.22, size.height * 0.24)
        ..lineTo(size.width * 0.31, size.height * 0.18),
      Path()
        ..moveTo(size.width, size.height * 0.70)
        ..lineTo(size.width * 0.78, size.height * 0.70)
        ..lineTo(size.width * 0.69, size.height * 0.77),
      Path()
        ..moveTo(size.width * 0.68, 0)
        ..lineTo(size.width * 0.68, size.height * 0.12)
        ..lineTo(size.width * 0.60, size.height * 0.18),
    ];
    for (final path in paths) {
      canvas.drawPath(path, circuitPaint);
    }

    const glyphs = <_TechGlyph>[
      _TechGlyph(Icons.laptop_mac_rounded, 0.14, 0.16, 34, -0.08),
      _TechGlyph(Icons.mouse_rounded, 0.84, 0.18, 28, 0.09),
      _TechGlyph(Icons.keyboard_rounded, 0.13, 0.56, 34, 0.05),
      _TechGlyph(Icons.headphones_rounded, 0.88, 0.52, 32, -0.07),
      _TechGlyph(Icons.memory_rounded, 0.20, 0.84, 30, 0.06),
      _TechGlyph(Icons.speaker_rounded, 0.82, 0.84, 29, -0.05),
    ];

    for (final glyph in glyphs) {
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(glyph.icon.codePoint),
          style: TextStyle(
            fontFamily: glyph.icon.fontFamily,
            package: glyph.icon.fontPackage,
            fontSize: glyph.size,
            color: AppColors.onBrand.withValues(alpha: 0.075),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(size.width * glyph.x, size.height * glyph.y);
      canvas.rotate(glyph.rotation);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TechGlyph {
  const _TechGlyph(this.icon, this.x, this.y, this.size, this.rotation);

  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double rotation;
}
