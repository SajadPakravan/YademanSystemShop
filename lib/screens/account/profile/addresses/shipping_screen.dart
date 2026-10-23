import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/address/shipping_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/shipping_view.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key, required this.addressesViewModel});

  final AddressesViewModel addressesViewModel;

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  late final ShippingViewModel _viewModel;

  /// ایجاد یک ViewModel مستقل برای فرم ارسال.
  @override
  void initState() {
    super.initState();
    _viewModel = ShippingViewModel(
      token: widget.addressesViewModel.token,
      shipping: widget.addressesViewModel.shipping!,
      provinces: widget.addressesViewModel.provinces,
      addressesViewModel: widget.addressesViewModel,
    );
  }

  /// آزادسازی کنترلرها پس از بسته‌شدن صفحه.
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// بازسازی فرم در واکنش به اعتبارسنجی و ذخیره آدرس.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => ShippingView(viewModel: _viewModel),
    );
  }
}
