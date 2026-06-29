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

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  PageController pageCtrl = PageController();
  int pageIndex = 0;
  IconData icnHome = Icons.home;
  IconData icnShop = Icons.store_outlined;
  IconData icnCategory = Icons.category_outlined;
  IconData icnAccount = Icons.person_outlined;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor: Colors.black,
    ));
    pageCtrl = PageController(initialPage: widget.pageIndex);
    pageIndex = widget.pageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => onTapMenu(index: widget.pageIndex)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView(
          controller: pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            ShopScreen(),
            CategoriesScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  bottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 3))),
      child: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) {
          onTapMenu(index: index);
          setState(() => pageCtrl.jumpToPage(index));
        },
        items: [
          BottomNavigationBarItem(icon: Icon(icnHome), label: "خانه"),
          BottomNavigationBarItem(icon: Icon(icnShop), label: "فروشگاه"),
          BottomNavigationBarItem(icon: Icon(icnCategory), label: "دسته‌بندی‌ها"),
          BottomNavigationBarItem(icon: Icon(icnAccount), label: "حساب من"),
        ],
      ),
    );
  }

  onTapMenu({required int index}) {
    switch (index) {
      case 0:
        {
          menuUnSelected();
          setState(() {
            pageIndex = index;
            icnHome = Icons.home;
          });
          break;
        }
      case 1:
        {
          menuUnSelected();
          setState(() {
            pageIndex = index;
            icnShop = Icons.store;
          });
          break;
        }
      case 2:
        {
          menuUnSelected();
          setState(() {
            pageIndex = index;
            icnCategory = Icons.category;
          });
          break;
        }
      case 3:
        {
          menuUnSelected();
          setState(() {
            pageIndex = index;
            icnAccount = Icons.person;
          });
          break;
        }
    }
  }

  menuUnSelected() {
    setState(() {
      icnHome = Icons.home_outlined;
      icnShop = Icons.store_outlined;
      icnCategory = Icons.category_outlined;
      icnAccount = Icons.person_outlined;
    });
  }
}
