import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/tools/products_local_store.dart';
import 'package:yad_sys/widgets/splash/splash_logo_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 3200);
  final HttpRequest _httpRequest = HttpRequest();
  late final AnimationController _logoController;
  late final AnimationController _backgroundController;
  late final MemoryImage _logoImage;
  late final DateTime _startedAt;
  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  _SplashConnectionState _connectionState = _SplashConnectionState.checking;
  bool _checkingConnection = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _startedAt = DateTime.now();
    _logoImage = MemoryImage(base64Decode(kYademanSplashLogoBase64));
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2850))..forward();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: const []);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConnectionMonitoring());
  }

  Future<void> _startConnectionMonitoring() async {
    _connectionSubscription = InternetConnectionChecker.instance.onStatusChange.listen(_handleConnectionStatus);
    await _checkConnection();
  }

  void _handleConnectionStatus(InternetConnectionStatus status) {
    if (!mounted || _navigated) {
      return;
    }

    if (status == InternetConnectionStatus.disconnected) {
      _setConnectionState(_SplashConnectionState.offline);
      return;
    }

    if (_connectionState != _SplashConnectionState.connected) {
      _checkConnection();
    }
  }

  Future<void> _checkConnection() async {
    if (_checkingConnection || _navigated) {
      return;
    }

    _checkingConnection = true;
    _setConnectionState(_SplashConnectionState.checking);

    try {
      final hasInternet = await InternetConnectionChecker.instance.hasConnection;

      if (!mounted || _navigated) {
        return;
      }

      if (!hasInternet) {
        _setConnectionState(_SplashConnectionState.offline);
        return;
      }

      // به جای یک درخواست بلااستفاده به API خانه، تمام کاتالوگ بدون
      // فیلتر را یک‌بار می‌گیریم. ProductsLocalStore فقط وقتی تمام
      // صفحات با موفقیت دریافت شوند، کش قبلی را به‌صورت اتمیک جایگزین می‌کند.
      await ProductsLocalStore.instance.refreshFullCatalog(_httpRequest);

      if (!mounted || _navigated) {
        return;
      }

      await _completeSplashAndNavigate();
    } catch (_) {
      if (mounted && !_navigated) {
        _setConnectionState(_SplashConnectionState.serverUnavailable);
      }
    } finally {
      _checkingConnection = false;
    }
  }

  Future<void> _completeSplashAndNavigate() async {
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _minimumSplashDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted || _navigated) {
      return;
    }

    _setConnectionState(_SplashConnectionState.connected);
    await Future<void>.delayed(const Duration(milliseconds: 520));

    if (!mounted || _navigated) {
      return;
    }

    _navigated = true;
    Get.offAll(const MainScreen(), transition: Transition.fade, duration: const Duration(milliseconds: 650));
  }

  void _setConnectionState(_SplashConnectionState value) {
    if (!mounted || _connectionState == value) {
      return;
    }

    setState(() {
      _connectionState = value;
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final compact = size.height < 680;
    final reduceMotion = mediaQuery.disableAnimations;
    final logoSize = math.min(size.width * (compact ? 0.62 : 0.70), size.height * (compact ? 0.40 : 0.43)).clamp(205.0, 390.0).toDouble();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff031f42),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashGradientBackground(),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return CustomPaint(painter: _TechBackgroundPainter(progress: reduceMotion ? 0.16 : _backgroundController.value));
                },
              ),
            ),
            const _BackgroundVignette(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, compact ? 10 : 18, 18, compact ? 12 : 20),
                child: Column(
                  children: [
                    const Spacer(),
                    _AnimatedBrandLogo(size: logoSize, imageProvider: _logoImage, controller: _logoController, reduceMotion: reduceMotion),
                    SizedBox(height: compact ? 10 : 16),
                    _BrandCaption(compact: compact),
                    const Spacer(),
                    _ConnectionPanel(state: _connectionState, compact: compact, onRetry: _checkConnection),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SplashConnectionState { checking, connected, offline, serverUnavailable }

class _SplashGradientBackground extends StatelessWidget {
  const _SplashGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xff0874d8), Color(0xff0457a8), Color(0xff033b78), Color(0xff021c3c)],
          stops: [0, 0.34, 0.68, 1],
        ),
      ),
    );
  }
}

class _BackgroundVignette extends StatelessWidget {
  const _BackgroundVignette();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.08),
          radius: 1.05,
          colors: [Color(0x0019baff), Color(0x18000f25), Color(0x76000b1d)],
          stops: [0, 0.64, 1],
        ),
      ),
    );
  }
}

class _BrandCaption extends StatelessWidget {
  const _BrandCaption({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'فروشگاه تخصصی محصولات دیجیتال',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
        ),
        const SizedBox(height: 5),
        Text(
          'انتخاب هوشمند، خرید مطمئن',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: compact ? 11 : 12.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _AnimatedBrandLogo extends StatelessWidget {
  const _AnimatedBrandLogo({required this.size, required this.imageProvider, required this.controller, required this.reduceMotion});

  final double size;
  final ImageProvider imageProvider;
  final AnimationController controller;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final value = reduceMotion ? 1.0 : controller.value;

          final laptop = _interval(value, 0.02, 0.30, Curves.easeOutBack);
          final yademan = _interval(value, 0.24, 0.56, Curves.easeOutCubic);
          final system = _interval(value, 0.44, 0.70, Curves.easeOutCubic);
          final frame = _interval(value, 0.58, 0.92, Curves.easeInOutCubic);
          final finalLogo = _interval(value, 0.88, 1.0, Curves.easeOut);

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff001127).withValues(alpha: 0.38),
                  blurRadius: size * 0.10,
                  spreadRadius: size * 0.012,
                  offset: Offset(0, size * 0.045),
                ),
                BoxShadow(color: const Color(0xff49ddff).withValues(alpha: 0.16), blurRadius: size * 0.11, spreadRadius: size * 0.006),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: 0.68 + (0.32 * laptop),
                  child: Opacity(
                    opacity: laptop.clamp(0.0, 1.0),
                    child: ClipRect(
                      clipper: const _LogoRegionClipper(region: Rect.fromLTWH(0.13, 0.07, 0.74, 0.57)),
                      child: Image(image: imageProvider, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 10 * (1 - yademan)),
                  child: ClipRect(
                    clipper: _LogoWritingClipper(region: const Rect.fromLTWH(0.08, 0.63, 0.84, 0.17), progress: yademan),
                    child: Image(image: imageProvider, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 8 * (1 - system)),
                  child: ClipRect(
                    clipper: _LogoWritingClipper(region: const Rect.fromLTWH(0.25, 0.79, 0.50, 0.12), progress: system),
                    child: Image(image: imageProvider, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                  ),
                ),
                CustomPaint(painter: _LogoFramePainter(progress: frame)),
                Opacity(
                  opacity: finalLogo,
                  child: Image(image: imageProvider, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static double _interval(double value, double begin, double end, Curve curve) {
    final normalized = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(normalized.toDouble());
  }
}

class _LogoRegionClipper extends CustomClipper<Rect> {
  const _LogoRegionClipper({required this.region});

  final Rect region;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(region.left * size.width, region.top * size.height, region.right * size.width, region.bottom * size.height);
  }

  @override
  bool shouldReclip(covariant _LogoRegionClipper oldClipper) {
    return region != oldClipper.region;
  }
}

class _LogoWritingClipper extends CustomClipper<Rect> {
  const _LogoWritingClipper({required this.region, required this.progress});

  final Rect region;
  final double progress;

  @override
  Rect getClip(Size size) {
    final target = Rect.fromLTRB(region.left * size.width, region.top * size.height, region.right * size.width, region.bottom * size.height);
    final visibleWidth = target.width * progress.clamp(0.0, 1.0).toDouble();
    return Rect.fromLTWH(target.left, target.top, visibleWidth, target.height);
  }

  @override
  bool shouldReclip(covariant _LogoWritingClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.region != region;
  }
}

class _LogoFramePainter extends CustomPainter {
  const _LogoFramePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0).toDouble();

    if (p <= 0) {
      return;
    }

    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.444;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = const SweepGradient(colors: [Color(0xff223442), Color(0xff45bdd7), Color(0xffd7d94d), Color(0xff6f914f), Color(0xff223442)]);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.022
      ..shader = gradient.createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * p, false, outerPaint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.012
      ..color = const Color(0xff1f303d).withValues(alpha: 0.92 * p);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.93), math.pi / 2, -math.pi * 2 * p, false, innerPaint);

    final headAngle = -math.pi / 2 + (math.pi * 2 * p);
    final head = Offset(center.dx + math.cos(headAngle) * radius, center.dy + math.sin(headAngle) * radius);

    canvas.drawCircle(head, size.shortestSide * 0.014, Paint()..color = Colors.white.withValues(alpha: 0.92 * p));
  }

  @override
  bool shouldRepaint(covariant _LogoFramePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({required this.state, required this.compact, required this.onRetry});

  final _SplashConnectionState state;
  final bool compact;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: Tween<double>(begin: 0.96, end: 1).animate(animation), child: child),
          );
        },
        child: switch (state) {
          _SplashConnectionState.checking => _CheckingConnectionCard(compact: compact),
          _SplashConnectionState.connected => _ConnectedCard(compact: compact),
          _SplashConnectionState.offline => _ConnectionErrorCard(
            key: const ValueKey('offline'),
            compact: compact,
            icon: Icons.wifi_off_rounded,
            title: 'اینترنت در دسترس نیست',
            message: 'اتصال اینترنت را بررسی کنید و سپس دوباره تلاش کنید.',
            onRetry: onRetry,
          ),
          _SplashConnectionState.serverUnavailable => _ConnectionErrorCard(
            key: const ValueKey('server'),
            compact: compact,
            icon: Icons.cloud_off_rounded,
            title: 'ارتباط با فروشگاه برقرار نشد',
            message: 'اگر VPN یا فیلترشکن روشن است آن را خاموش کنید؛ سپس وضعیت اینترنت و دسترسی به سرور را دوباره بررسی کنید.',
            onRetry: onRetry,
          ),
        },
      ),
    );
  }
}

class _CheckingConnectionCard extends StatelessWidget {
  const _CheckingConnectionCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      key: const ValueKey('checking'),
      compact: compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
          const SizedBox(width: 12),
          Text(
            'در حال اتصال به فروشگاه…',
            style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 13.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  const _ConnectedCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      key: const ValueKey('connected'),
      compact: compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xff75f5ad), size: 26),
          const SizedBox(width: 10),
          Text(
            'اتصال برقرار شد',
            style: TextStyle(color: Colors.white, fontSize: compact ? 12.5 : 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ConnectionErrorCard extends StatelessWidget {
  const _ConnectionErrorCard({super.key, required this.compact, required this.icon, required this.title, required this.message, required this.onRetry});

  final bool compact;
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      compact: compact,
      maxWidth: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 42 : 48,
            height: compact ? 42 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: Colors.white, size: compact ? 23 : 27),
          ),
          SizedBox(height: compact ? 8 : 11),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: compact ? 10.5 : 11.8, height: 1.6, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: compact ? 9 : 13),
          SizedBox(
            height: compact ? 38 : 42,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('تلاش مجدد', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff0759a8),
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({super.key, required this.compact, required this.child, this.maxWidth = 420});

  final bool compact;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20, vertical: compact ? 11 : 14),
        decoration: BoxDecoration(
          color: const Color(0xff061a35).withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: child,
      ),
    );
  }
}

class _TechBackgroundPainter extends CustomPainter {
  const _TechBackgroundPainter({required this.progress});

  final double progress;

  static const List<_TechGlyph> _glyphs = [
    _TechGlyph(Icons.laptop_mac_rounded, 0.12, 0.18, 44, 0.8, 0.1),
    _TechGlyph(Icons.mouse_rounded, 0.84, 0.17, 34, -0.7, 0.8),
    _TechGlyph(Icons.keyboard_rounded, 0.16, 0.73, 42, -0.5, 1.7),
    _TechGlyph(Icons.desktop_windows_rounded, 0.83, 0.70, 46, 0.55, 2.4),
    _TechGlyph(Icons.speaker_rounded, 0.91, 0.42, 33, 0.7, 1.1),
    _TechGlyph(Icons.usb_rounded, 0.08, 0.45, 29, -0.9, 2.9),
    _TechGlyph(Icons.headphones_rounded, 0.27, 0.88, 36, 0.65, 4.2),
    _TechGlyph(Icons.memory_rounded, 0.72, 0.90, 31, -0.75, 3.4),
    _TechGlyph(Icons.router_rounded, 0.68, 0.08, 33, 0.45, 5.0),
    _TechGlyph(Icons.phone_android_rounded, 0.35, 0.08, 29, -0.55, 2.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    _paintGrid(canvas, size, progress);
    _paintCircuits(canvas, size, t);

    for (final glyph in _glyphs) {
      final bob = math.sin(t * glyph.speed + glyph.phase) * size.shortestSide * 0.018;
      final drift = math.cos(t * glyph.speed * 0.66 + glyph.phase) * size.shortestSide * 0.012;

      final position = Offset((glyph.x * size.width) + drift, (glyph.y * size.height) + bob);

      final rotation = math.sin(t * glyph.speed * 0.42 + glyph.phase) * 0.10;

      _paintGlyph(canvas, glyph.icon, position, glyph.size * (size.width / 430).clamp(0.82, 1.28), rotation);
    }
  }

  void _paintGrid(Canvas canvas, Size size, double progress) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const gap = 56.0;
    final horizontalOffset = (progress * gap) % gap;
    final verticalOffset = (progress * gap * 0.7) % gap;

    for (double x = -gap + horizontalOffset; x <= size.width + gap; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = -gap + verticalOffset; y <= size.height + gap; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintCircuits(Canvas canvas, Size size, double t) {
    final linePaint = Paint()
      ..color = const Color(0xff68d9ff).withValues(alpha: 0.07)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()..color = const Color(0xffb9f3ff).withValues(alpha: 0.13);

    final shift = math.sin(t * 0.35) * size.width * 0.018;

    final paths = <Path>[
      Path()
        ..moveTo(-20, size.height * 0.31)
        ..lineTo(size.width * 0.19 + shift, size.height * 0.31)
        ..lineTo(size.width * 0.27 + shift, size.height * 0.25),
      Path()
        ..moveTo(size.width + 20, size.height * 0.58)
        ..lineTo(size.width * 0.80 - shift, size.height * 0.58)
        ..lineTo(size.width * 0.72 - shift, size.height * 0.64),
      Path()
        ..moveTo(size.width * 0.43, -10)
        ..lineTo(size.width * 0.43, size.height * 0.13)
        ..lineTo(size.width * 0.50, size.height * 0.18),
    ];

    for (final path in paths) {
      canvas.drawPath(path, linePaint);
    }

    final nodes = [
      Offset(size.width * 0.19 + shift, size.height * 0.31),
      Offset(size.width * 0.80 - shift, size.height * 0.58),
      Offset(size.width * 0.43, size.height * 0.13),
    ];

    for (final node in nodes) {
      canvas.drawCircle(node, 3.2, nodePaint);
    }
  }

  void _paintGlyph(Canvas canvas, IconData icon, Offset position, double fontSize, double rotation) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: fontSize, fontFamily: icon.fontFamily, package: icon.fontPackage, color: Colors.white.withValues(alpha: 0.075)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TechBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TechGlyph {
  const _TechGlyph(this.icon, this.x, this.y, this.size, this.speed, this.phase);

  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
}
