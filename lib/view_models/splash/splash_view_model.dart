import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/view_models/home/home_view_model.dart';

enum SplashConnectionState { checking, offline, serverUnavailable, connected }

class SplashViewModel with ChangeNotifier {
  SplashViewModel({required this._homeViewModel});

  final HomeViewModel _homeViewModel;
  final HttpRequest _httpRequest = HttpRequest();
  SplashConnectionState _state = SplashConnectionState.checking;
  bool _checking = false;

  SplashConnectionState get state => _state;

  bool get isChecking => _checking;

  bool get isConnected => _state == SplashConnectionState.connected;

  Future<void> checkConnection() async {
    if (_checking || isConnected) return;

    _checking = true;
    _setState(SplashConnectionState.checking);

    try {
      final hasInternet = await InternetConnectionChecker.instance.hasConnection;
      if (!hasInternet) {
        _setState(SplashConnectionState.offline);
        return;
      }

      final dynamic json = await _httpRequest.getHome();
      if (json['success'] == false) {
        _setState(SplashConnectionState.serverUnavailable);
        return;
      }

      _homeViewModel.useSplashResponse(Map<String, dynamic>.from(json));
      _setState(SplashConnectionState.connected);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('SPLASH CONNECTION ERROR >>>> $e');
        debugPrint('$stackTrace');
      }
      _setState(SplashConnectionState.serverUnavailable);
    } finally {
      _checking = false;
    }
  }

  void _setState(SplashConnectionState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }
}
