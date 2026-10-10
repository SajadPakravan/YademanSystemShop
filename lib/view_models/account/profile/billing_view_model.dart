import 'package:yad_sys/view_models/account/profile/address_form_view_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';

/// State and editing lifecycle exclusively for the billing tab.
class BillingViewModel extends AddressFormViewModel {
  BillingViewModel({required AddressesViewModel addressesViewModel})
      : super(addressesViewModel: addressesViewModel, kind: AddressKind.billing);
}
