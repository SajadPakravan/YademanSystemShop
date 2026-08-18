import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/splash/splash_view_model.dart';
import 'package:yad_sys/widgets/splash/splash_logo_data.dart';

final _splashLogoBytes = base64Decode(kYademanSplashLogoBase64);

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SplashViewModel>();
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 680;
    final logoSize = math.min(size.width * 0.58, size.height * 0.29).clamp(170.0, 310.0).toDouble();
    final titleSize = (size.width * 0.052).clamp(19.0, 25.0).toDouble();
    final subtitleSize = (size.width * 0.035).clamp(12.5, 15.5).toDouble();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SplashBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(math.max(22.0, size.width * 0.07), compact ? 26 : 44, math.max(22.0, size.width * 0.07), compact ? 24 : 34),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 2),
                  _LogoCard(size: logoSize),
                  SizedBox(height: compact ? 22 : 28),
                  Text(
                    'فروشگاه یادمان سیستم',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                      shadows: const <Shadow>[Shadow(color: Color(0x50000000), blurRadius: 12, offset: Offset(0, 3))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'فروشگاه تخصصی لپ‌تاپ، کامپیوتر و لوازم جانبی دیجیتال',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: subtitleSize, fontWeight: FontWeight.w500, height: 1.7),
                  ),
                  const Spacer(flex: 3),
                  _ConnectionCard(state: viewModel.state, onRetry: viewModel.checkConnection, compact: compact),
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
    return SizedBox(
      width: size,
      height: size,
      child: Image.memory(_splashLogoBytes, fit: BoxFit.contain),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.state, required this.onRetry, required this.compact});

  final SplashConnectionState state;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
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
        iconColor = const Color(0xff67d9ff);
        break;
      case SplashConnectionState.offline:
        icon = Icons.wifi_off_rounded;
        title = 'اتصال اینترنت برقرار نیست';
        description = 'اینترنت دستگاه را بررسی کنید و دوباره تلاش کنید';
        iconColor = const Color(0xffffca5c);
        break;
      case SplashConnectionState.serverUnavailable:
        icon = Icons.cloud_off_rounded;
        title = 'ارتباط با سرور برقرار نشد';
        description = 'وضعیت اینترنت را بررسی کنید و اگر VPN روشن است آن را خاموش کنید';
        iconColor = const Color(0xffff8d8d);
        break;
      case SplashConnectionState.connected:
        icon = Icons.check_circle_rounded;
        title = 'اتصال برقرار شد';
        description = 'در حال ورود به فروشگاه...';
        iconColor = const Color(0xff70e0a1);
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18, vertical: compact ? 12 : 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: <Widget>[
          if (state == SplashConnectionState.checking)
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: iconColor))
          else
            Icon(icon, color: iconColor, size: 35),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5, height: 1.55),
                ),
              ],
            ),
          ),
          if (showRetry) ...<Widget>[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('تلاش دوباره'),
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[Color(0xff061b33), Color(0xff073d6d), Color(0xff0353a4), Color(0xff05223f)],
          stops: <double>[0, 0.36, 0.68, 1],
        ),
      ),
      child: CustomPaint(painter: _TechBackgroundPainter()),
    );
  }
}

class _TechBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const grid = 46.0;
    for (double x = 0; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final circuitPaint = Paint()
      ..color = const Color(0xff70d8ff).withValues(alpha: 0.085)
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

    final glyphs = <_TechGlyph>[
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
            color: Colors.white.withValues(alpha: 0.075),
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
