import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/view_models/home/home_view_model.dart';
import 'package:yad_sys/view_models/splash/splash_view_model.dart';
import 'package:yad_sys/views/splash/splash_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minimumVisibleTime = Duration(milliseconds: 1200);

  SplashViewModel? _viewModel;
  late final DateTime _startedAt;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_viewModel != null) return;
    _viewModel = SplashViewModel(homeViewModel: context.read<HomeViewModel>())..addListener(_handleStateChanged);
    _viewModel!.checkConnection();
  }

  void _handleStateChanged() {
    final viewModel = _viewModel;
    if (viewModel == null || !viewModel.isConnected || _navigated) return;

    _navigated = true;
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _minimumVisibleTime - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    Get.offAll(const MainScreen(), transition: Transition.fade, duration: const Duration(milliseconds: 320));
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_handleStateChanged);
    _viewModel?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) return const SizedBox.shrink();

    return ChangeNotifierProvider<SplashViewModel>.value(value: viewModel, child: const SplashView());
  }
}
