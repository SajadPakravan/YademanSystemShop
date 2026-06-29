import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_texts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class AppThemes {
  AppDimension appDimension = AppDimension();
  AppTexts appTexts = AppTexts();

  systemTheme() {
    Brightness brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    if (kDebugMode) {
      print("Brightness >>>> $brightness");
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ColorStyle.opacity0,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  blueTheme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: ColorStyle.blueFav,
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: Colors.black87,
          fontFamily: appTexts.appFont,
          fontWeight: FontWeight.normal,
          fontSize: appDimension.textNormal,
        ),
        bodyMedium: TextStyle(
          color: Colors.black87,
          fontFamily: appTexts.appFont,
          fontWeight: FontWeight.normal,
          fontSize: appDimension.textNormal,
        ),
        labelMedium: TextStyle(
          color: Colors.black54,
          fontFamily: appTexts.appFont,
          fontWeight: FontWeight.normal,
          fontSize: appDimension.textNormal,
        ),
      ),
    );
  }
}

extension CustomStyles on TextTheme {
  get appDimension => AppDimension();

  get appTexts => AppTexts();

  TextStyle get buttonText1 {
    return TextStyle(
      color: Colors.white,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
    );
  }

  TextStyle get textField {
    return TextStyle(
      color: Colors.black87,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
      height: 2,
    );
  }

  TextStyle get txtBtnBlue {
    return TextStyle(
      color: ColorStyle.blueFav,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
    );
  }

  TextStyle get menu {
    return TextStyle(
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
    );
  }

  TextStyle get profileMenu {
    return TextStyle(
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.menuText2,
    );
  }

  TextStyle get homeMenu {
    return TextStyle(
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.homeMenu,
    );
  }

  TextStyle get quantityProduct {
    return TextStyle(
      color: Colors.red,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.bold,
      fontSize: appDimension.textNormal,
    );
  }

  TextStyle get yadsys {
    return TextStyle(
      color: Colors.red,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.bold,
      fontSize: appDimension.textTitle,
    );
  }

  TextStyle get hintText {
    return TextStyle(
      color: Colors.black54,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
      height: 0,
    );
  }

  TextStyle get errorText1 {
    return TextStyle(
      color: Colors.white,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.bold,
      fontSize: appDimension.textError,
    );
  }

  TextStyle get errorText3 {
    return TextStyle(
      color: Colors.red,
      fontFamily: appTexts.appFont,
      fontSize: appDimension.textError,
    );
  }

  TextStyle get errorText2 {
    return TextStyle(
      color: Colors.black87,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.normal,
      fontSize: appDimension.textNormal,
      height: 2,
    );
  }

  TextStyle get price {
    return TextStyle(
      color: Colors.black87,
      fontFamily: appTexts.appFont,
      fontWeight: FontWeight.bold,
      fontSize: appDimension.textNormal,
    );
  }
}
