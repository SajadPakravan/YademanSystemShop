import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';

/// Legacy color aliases kept so old screens compile while new code uses AppColors/context.appColors.
class ColorStyle {
  static const Color gray12 = AppColors.lightBorder;
  static const Color opacity0 = AppColors.transparent;
  static const Gradient gradientBlue = LinearGradient(
    colors: <Color>[Color(0xff063a70), AppColors.primary, AppColors.secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const Color progressColor = AppColors.lightTextMuted;
  static const MaterialColor blueFav = MaterialColor(
    0xff0353a4,
    <int, Color>{
      50: Color(0xff0353a4), 100: Color(0xff0353a4), 200: Color(0xff0353a4), 300: Color(0xff0353a4),
      400: Color(0xff0353a4), 500: Color(0xff0353a4), 600: Color(0xff0353a4), 700: Color(0xff0353a4),
      800: Color(0xff0353a4), 900: Color(0xff0353a4),
    },
  );
  static const Color darkBlue = AppColors.primaryDark;
  static const Color colorPurple = AppColors.secondary;
  static const Color colorPurple2 = Color(0xff2e43a9);
  static const Color colorPurpleDark = Color(0xff0b1e64);
  static const Color colorPurpleDarkBorder = Color(0xff2b43a4);
  static const Color colorBlack0a = AppColors.lightTextPrimary;
  static const Color colorWhiteE7 = AppColors.lightDivider;
  static const Color colorBlack13 = Color(0xff131b25);
  static const Color whiteF5 = AppColors.lightBackground;
  static const Color colorBlack1b = Color(0xff1b2936);
  static const Color colorWhite = AppColors.lightSurface;
  static const Color colorBlack24 = Color(0xff243547);
  static const Color colorYellow = AppColors.star;
  static const Color colorPink = AppColors.accent;
  static const Color colorPinkF9 = Color(0xfff94e4e);
  static const Color colorOrange = Color(0xffff8b29);
  static const Color colorGreen = AppColors.success;
  static const Color colorGreenLight = Color(0xff80ffb2);
  static const Color colorRed = AppColors.error;
  static const Color colorBlue = Color(0xff00dbff);
  static const Color colorBlueLight = Color(0xff8be7fa);
  static const Color colorBlue1 = AppColors.primary;
  static const Color colorBlue2 = Color(0x350353a4);
  static const Color colorFont42 = Color(0xff424242);
  static const Color colorWhiteCB = Color(0xffcbcbcb);
  static const Color colorGrey = AppColors.lightTextMuted;
  static const Color colorWhiteGR = AppColors.lightBorder;
  static const Color colorGrayB4 = Color(0xffcccccc);
  static const Color colorPinkApp = AppColors.accent;
  static const Color colorPinkBack = Color(0xffff7be6);
  static const Color backgroundItemColorDashboardUnSelected = Color.fromRGBO(196, 196, 196, 1.0);
  static const Color backgroundColorDashboard = AppColors.lightBackground;
}
