import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/address/address_form_view_model.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/views/account/profile/addresses/billing_view.dart';
import 'package:yad_sys/views/account/profile/addresses/shipping_view.dart';

/// مدیریت چرخه عمر یک فرم آدرس؛ برای هر مسیر صفحه، نمونه جدا ساخته می‌شود.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, required this.addressesViewModel, required this.addressKey})
    : assert(addressKey == 'billing' || addressKey == 'shipping');

  final AddressesViewModel addressesViewModel;
  final String addressKey;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final AddressFormViewModel _viewModel;

  /// ایجاد یک ViewModel مستقل برای همان نوع آدرس هنگام ورود به صفحه.
  @override
  void initState() {
    super.initState();
    _viewModel = AddressFormViewModel(
      token: widget.addressesViewModel.token,
      address: widget.addressKey == 'billing' ? widget.addressesViewModel.billing! : widget.addressesViewModel.shipping!,
      addressKey: widget.addressKey,
      provinces: widget.addressesViewModel.provinces,
      addressesViewModel: widget.addressesViewModel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => widget.addressKey == 'billing' ? BillingView(viewModel: _viewModel) : ShippingView(viewModel: _viewModel),
    );
  }
}
