import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/app_texts.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  HttpRequest httpRequest = HttpRequest();
  bool opacity = false;
  AppTexts appTexts = AppTexts();
  bool connectionStatus = true;
  bool confirm = false;
  bool internetStatus = true;
  bool tryAgain = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    checkConnection();
  }

  Future<void> checkConnection() async {
    if (tryAgain) {
      internetStatus = await InternetConnectionChecker.instance.hasConnection;
      if (internetStatus) {
        setState(() {
          connectionStatus = true;
          confirm = false;
        });
        urlCheckConnection();
      } else {
        setState(() {
          connectionStatus = false;
          confirm = false;
        });
      }
    } else {
      InternetConnectionChecker.instance.onStatusChange.listen((status) async {
        internetStatus = status == InternetConnectionStatus.connected;
        if (internetStatus) {
          setState(() {
            connectionStatus = true;
            confirm = false;
          });
          urlCheckConnection();
        } else {
          setState(() {
            connectionStatus = false;
            confirm = false;
          });
        }
      });
    }
  }

  Future<void> urlCheckConnection() async {
    dynamic result = await httpRequest.getProducts();
    if (result != false) {
      setState(() => confirm = true);
      Timer(
        const Duration(seconds: 2),
        () => Get.offAll(const MainScreen(), transition: Transition.fade, duration: const Duration(seconds: 1)),
      );
    } else {
      setState(() {
        connectionStatus = false;
        confirm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorStyle.blueFav,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: SimpleShadow(
            color: Colors.black,
            offset: const Offset(-25, 15),
            child: Image.asset("assets/images/logos/application_logo.png", fit: BoxFit.contain, scale: width * 0.009),
          ),
        ),
      ),
      bottomNavigationBar: connectionStatus
          ? IntrinsicHeight(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: width * 0.04),
                child: confirm ? const Icon(Icons.check_circle_outline, color: Colors.white, size: 50) : const Loading(color: Colors.white),
              ),
            )
          : IntrinsicHeight(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: width * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const TextBodyLargeView(
                      "مشکل در اتصال\n"
                      "لطفا فیلترشکن را خاموش کرده و وضعیت اینترنت را بررسی کنید",
                      color: Colors.white,
                      height: 1.7,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(top: width * 0.02),
                      width: width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tryAgain = true;
                          });
                          checkConnection();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.autorenew_rounded, color: Colors.white),
                            TextBodyMediumView("تلاش مجدد", color: Colors.white)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
