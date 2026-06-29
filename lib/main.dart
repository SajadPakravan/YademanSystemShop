import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/database/favorite_model.dart';
import 'package:yad_sys/models/category_model.dart';
import 'package:yad_sys/screens/splash/splash_screen.dart';
import 'package:yad_sys/themes/theme.dart';
import 'package:yad_sys/tools/app_texts.dart';
import 'package:yad_sys/view_models/categories/categories_view_model.dart';
import 'package:yad_sys/view_models/home/home_view_model.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(CartModelAdapter());
  await Hive.openBox<CartModel>('cartBox');
  Hive.registerAdapter(FavoriteModelAdapter());
  await Hive.openBox<FavoriteModel>('favoritesBox');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ShopViewModel()),
        ChangeNotifierProvider(create: (_) => CategoriesViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryModel()),
      ],
      child: const YademanSystemShop(),
    ),
  );
}

class YademanSystemShop extends StatefulWidget {
  const YademanSystemShop({super.key});

  @override
  State<YademanSystemShop> createState() => _YademanSystemShop();
}

class _YademanSystemShop extends State<YademanSystemShop> {
  @override
  Widget build(BuildContext context) {
    AppTexts appTextStrings = AppTexts();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTextStrings.appTitle,
      useInheritedMediaQuery: true,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}
