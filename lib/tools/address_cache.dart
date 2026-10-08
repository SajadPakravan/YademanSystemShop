import 'package:yad_sys/models/address_model.dart';

/// کش اختیاری فقط در حافظه برای اطلاعات آدرس، نه SharedPreferences.
class AddressCache {
  AddressCache._();
  static final AddressCache instance = AddressCache._();
  AddressBookModel? _address;

  /// خواندن نسخه موقت دفترچه آدرس.
  AddressBookModel? get() => _address;
  /// ثبت نسخه جدید دفترچه آدرس در حافظه.
  void save(AddressBookModel address) => _address = address;
  /// حذف نسخه موقت در خروج از حساب.
  void clear() => _address = null;
}
