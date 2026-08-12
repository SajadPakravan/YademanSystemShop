import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yad_sys/view_models/shop/shop_view_model.dart';
import 'package:yad_sys/views/shop/shop_view.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    // read() در initState به Provider گوش نمی‌دهد. اگر Splash کاتالوگ را
    // آماده کرده باشد، loadInitial قبل از اولین build فیلترها را از کش پر می‌کند.
    context.read<ShopViewModel>().loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, shopModel, child) {
        return ShopView(viewModel: shopModel);
      },
    );
  }
}
