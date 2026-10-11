import 'package:yad_sys/view_models/account/profile/address_form_view_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';

class ShippingViewModel extends AddressFormViewModel {
  ShippingViewModel({required super.addressesViewModel})
      : super(kind: AddressKind.shipping);
}
