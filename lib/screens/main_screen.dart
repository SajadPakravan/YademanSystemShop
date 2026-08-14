import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yad_sys/screens/categories/categories_screen.dart';
import 'package:yad_sys/screens/home/home_screen.dart';
import 'package:yad_sys/screens/profile/profile_screen.dart';
import 'package:yad_sys/screens/shop/shop_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.pageIndex = 0});

  final int pageIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int pageIndex;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.black,
      ),
    );

    pageIndex = widget.pageIndex.clamp(0, 3);
    _pages = List<Widget?>.filled(4, null);
    _pages[pageIndex] = _createPage(pageIndex);
  }

  Widget _createPage(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const ShopScreen(),
      2 => const CategoriesScreen(),
      3 => const ProfileScreen(),
      _ => const HomeScreen(),
    };
  }

  void _openPage(int index) {
    if (index == pageIndex) return;

    setState(() {
      _pages[index] ??= _createPage(index);
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            for (var index = 0; index < _pages.length; index++)
              if (_pages[index] != null)
                Positioned.fill(
                  child: Offstage(
                    offstage: pageIndex != index,
                    child: TickerMode(enabled: pageIndex == index, child: _pages[index]!),
                  ),
                ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12, width: 3)),
          ),
          child: BottomNavigationBar(
            currentIndex: pageIndex,
            onTap: _openPage,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(pageIndex == 0 ? Icons.home : Icons.home_outlined), label: 'خانه'),
              BottomNavigationBarItem(icon: Icon(pageIndex == 1 ? Icons.store : Icons.store_outlined), label: 'فروشگاه'),
              BottomNavigationBarItem(icon: Icon(pageIndex == 2 ? Icons.category : Icons.category_outlined), label: 'دسته‌بندی‌ها'),
              BottomNavigationBarItem(icon: Icon(pageIndex == 3 ? Icons.person : Icons.person_outlined), label: 'حساب من'),
            ],
          ),
        ),
      ),
    );
  }
}
