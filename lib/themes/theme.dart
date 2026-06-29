import 'package:flutter/material.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/themes/text_styles.dart';

ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: colorScheme(),
  fontFamily: "IranYekan",
  primaryColor: ColorStyle.colorPurple,
  scaffoldBackgroundColor: Colors.white,
  canvasColor: ColorStyle.colorWhite,
  cardColor: ColorStyle.colorWhite,
  focusColor: ColorStyle.colorPurple,
  textTheme: const TextTheme(
    headlineLarge: TextStylesLight.blackF25,
    titleLarge: TextStylesLight.blackF20,
    titleMedium: TextStylesLight.blackF18,
    titleSmall: TextStylesLight.blackF16,
    bodyLarge: TextStylesLight.blackF16,
    bodyMedium: TextStylesLight.blackF14,
    bodySmall: TextStylesLight.blackF12,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(fontSize: 12),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorStyle.colorPurple)),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: ColorStyle.colorWhite),
  bottomNavigationBarTheme: bottomNavigationBarTheme(),
  appBarTheme: const AppBarTheme(backgroundColor: ColorStyle.colorPurple),
  iconTheme: const IconThemeData(color: ColorStyle.whiteF5),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(ColorStyle.blueFav)),
  ),
);

colorScheme() {
  return const ColorScheme.light(
    primary: ColorStyle.colorPurple,
    background: ColorStyle.whiteF5,
  );
}

bottomNavigationBarTheme() {
  return const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    unselectedLabelStyle: TextStylesLight.blackF14,
    selectedLabelStyle: TextStylesLight.blackF14,
    unselectedItemColor: Colors.grey,
    selectedItemColor: Colors.black87,
  );
}
