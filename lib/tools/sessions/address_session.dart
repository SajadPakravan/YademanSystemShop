import 'package:yad_sys/models/address_model.dart';

class AddressSession {
  AddressSession._();

  static AddressModel? _address;

  static AddressModel? get() => _address;

  static void save(AddressModel address) => _address = address;

  static void clear() => _address = null;
}
