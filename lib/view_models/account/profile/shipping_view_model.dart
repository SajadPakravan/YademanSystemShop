import 'package:yad_sys/view_models/account/profile/address_form_view_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';

/// State and editing lifecycle exclusively for the shipping tab.
class ShippingViewModel extends AddressFormViewModel {
  ShippingViewModel({required AddressesViewModel addressesViewModel})
      : super(addressesViewModel: addressesViewModel, kind: AddressKind.shipping);
}
