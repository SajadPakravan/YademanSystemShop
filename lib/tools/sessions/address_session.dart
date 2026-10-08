import 'package:yad_sys/models/address_model.dart';

/// کش اختیاری فقط در حافظه برای اطلاعات آدرس، نه SharedPreferences.
class AddressSession {
  AddressSession._();

  static AddressBookModel? _address;

  AddressBookModel? get() => _address;

  static void save(AddressBookModel address) => _address = address;

  static void clear() => _address = null;
}
