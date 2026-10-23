import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_log.dart';
import 'package:yad_sys/tools/sessions/address_session.dart';

class AddressesViewModel extends ChangeNotifier {
  AddressesViewModel({required this.token, HttpRequest? httpRequest}) : addresses = AddressSession.get(), httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  final String token;
  AddressModel? addresses;
  bool isLoading = false;
  String errorMessage = '';

  AddressFieldsModel? get billing => addresses?.billing;

  AddressFieldsModel? get shipping => addresses?.shipping;

  List<Province> get provinces => addresses!.locations.provinces;

  String state(String code) {
    for (final province in provinces) {
      if (code == province.code) return province.name;
    }
    return '';
  }

  Future<void> load() async {
    if (isLoading || addresses != null) return;

    isLoading = addresses == null;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await httpRequest.getAddresses(token: token);

      if (response['success'] != true) {
        errorMessage = response['message']?.toString() ?? 'دریافت آدرس‌ها انجام نشد.';
        return;
      }

      final addressesResponse = AddressesResponseModel.fromJson(Map<String, dynamic>.from(response as Map)).data;
      addresses = addressesResponse;
      AddressSession.save(addressesResponse);
    } catch (e, stack) {
      AppLog.error('ADDRESSES LOAD ERROR >>> $e\n$stack');
      errorMessage = 'اطلاعات آدرس دریافت شد اما ساختار آن معتبر نیست یا ارتباط قطع شده است.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// همگام‌سازی آدرس‌های ثبت‌شده در پیش‌نمایش و Session.
  void applyAddresses(AddressModel updated) {
    addresses = updated;
    AddressSession.save(updated);
    notifyListeners();
  }

  static const List<FieldMeta> fieldDefinitions = [
    FieldMeta(keyName: 'first_name', label: 'نام', icon: Icons.person_outline_rounded),
    FieldMeta(keyName: 'last_name', label: 'نام خانوادگی', icon: Icons.badge_outlined),
    FieldMeta(keyName: 'company', label: 'شرکت', icon: Icons.business_outlined),
    FieldMeta(keyName: 'state', label: 'استان', icon: Icons.map_outlined),
    FieldMeta(keyName: 'city', label: 'شهر', icon: Icons.location_city_outlined),
    FieldMeta(keyName: 'address_1', label: 'منطقه و خیابان', icon: Icons.location_on_outlined),
    FieldMeta(keyName: 'address_2', label: 'کوچه و پلاک', icon: Icons.add_location_alt_outlined),
    FieldMeta(keyName: 'postcode', label: 'کدپستی', icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
    FieldMeta(keyName: 'phone', label: 'شماره همراه', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
    FieldMeta(keyName: 'email', label: 'ایمیل', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
  ];

  List<FieldMeta> visibleFields(AddressFieldsModel model) => fieldDefinitions.where((field) => model.hasField(field.keyName)).toList();

}

class FieldMeta {
  const FieldMeta({required this.keyName, required this.label, required this.icon, this.keyboardType = TextInputType.text});

  final String keyName;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
}
