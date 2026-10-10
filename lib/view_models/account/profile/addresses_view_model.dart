import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/tools/app_log.dart';
import 'package:yad_sys/tools/sessions/address_session.dart';

enum AddressKind { billing, shipping }

extension AddressKindX on AddressKind {
  String get apiKey => this == AddressKind.billing ? 'billing' : 'shipping';
  String get title => this == AddressKind.billing ? 'صورتحساب' : 'ارسال';
}

/// Owns API, shared data and location lists, not any TextEditingController.
class AddressesViewModel extends ChangeNotifier {
  AddressesViewModel({required this.token, AddressModel? initialAddresses, HttpRequest? httpRequest})
      : addresses = AddressSession.get() ?? initialAddresses,
        httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  final String token;
  AddressModel? addresses;
  bool isLoading = false;
  bool isRefreshing = false;
  String errorMessage = '';
  final Map<AddressKind, String> _saveErrors = <AddressKind, String>{};
  String saveErrorFor(AddressKind kind) => _saveErrors[kind] ?? '';
  void clearSaveError(AddressKind kind) => _saveErrors.remove(kind);
  final Set<AddressKind> _saving = <AddressKind>{};
  bool _disposed = false;

  AddressFieldsModel? address(AddressKind kind) => kind == AddressKind.billing ? addresses?.billing : addresses?.shipping;
  List<LocationOptions> get provinces => addresses?.locations.provinces ?? const <LocationOptions>[];
  List<LocationOptions> citiesFor(String provinceCode) => addresses?.locations.citiesFor(provinceCode) ?? const <LocationOptions>[];
  bool saving(AddressKind kind) => _saving.contains(kind);
  bool get anySaving => _saving.isNotEmpty;

  static const List<FieldMeta> fieldDefinitions = <FieldMeta>[
    FieldMeta(keyName: 'first_name', label: 'نام', icon: Icons.person_outline_rounded),
    FieldMeta(keyName: 'last_name', label: 'نام خانوادگی', icon: Icons.badge_outlined),
    FieldMeta(keyName: 'company', label: 'شرکت', icon: Icons.business_outlined),
    FieldMeta(keyName: 'country', label: 'کشور', icon: Icons.public_rounded),
    FieldMeta(keyName: 'state', label: 'استان', icon: Icons.map_outlined),
    FieldMeta(keyName: 'city', label: 'شهر', icon: Icons.location_city_outlined),
    FieldMeta(keyName: 'address_1', label: 'آدرس اصلی', icon: Icons.location_on_outlined),
    FieldMeta(keyName: 'address_2', label: 'ادامه آدرس', icon: Icons.add_location_alt_outlined),
    FieldMeta(keyName: 'postcode', label: 'کدپستی', icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
    FieldMeta(keyName: 'phone', label: 'شماره همراه', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
    FieldMeta(keyName: 'email', label: 'ایمیل', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
  ];

  List<FieldMeta> visibleFields(AddressFieldsModel model) =>
      fieldDefinitions.where((field) => model.hasField(field.keyName)).toList(growable: false);

  static bool _validResponse(dynamic response) {
    if (response is! Map || response['success'] != true) return false;
    final code = response['status_code'];
    return code == null || (code is int && code >= 200 && code < 300);
  }

  Future<void> load({bool refresh = false}) async {
    if (_disposed || isLoading || isRefreshing || anySaving) return;
    if (!refresh && addresses != null) return;

    isLoading = addresses == null;
    isRefreshing = !isLoading;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await httpRequest.getAddresses(token: token);
      if (_disposed) return;
      if (!_validResponse(response)) {
        errorMessage = response is Map ? response['message']?.toString() ?? 'دریافت آدرس‌ها انجام نشد.' : 'دریافت آدرس‌ها انجام نشد.';
        return;
      }
      final newAddresses = AddressesResponseModel.fromJson(Map<String, dynamic>.from(response as Map)).data;
      addresses = newAddresses;
      AddressSession.save(newAddresses);
    } catch (e, stack) {
      AppLog.error('ADDRESSES LOAD ERROR >>> $e\n$stack');
      errorMessage = 'اطلاعات آدرس دریافت شد اما ساختار آن معتبر نیست یا ارتباط قطع شده است.';
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  /// PUT acknowledges a write; a fresh GET is the authoritative editable snapshot.
  /// Never merge stale local values into the API's enabled field set.
  Future<bool> updateAddress(AddressKind kind, Map<String, String> changes) async {
    if (_disposed || changes.isEmpty || anySaving || isLoading || isRefreshing || addresses == null) return false;
    _saveErrors.remove(kind);
    _saving.add(kind);
    notifyListeners();
    try {
      final response = await httpRequest.updateAddresses(token: token, changes: <String, dynamic>{kind.apiKey: changes});
      if (_disposed) return false;
      if (!_validResponse(response)) {
        _saveErrors[kind] = response is Map ? response['message']?.toString() ?? 'ذخیره آدرس انجام نشد.' : 'ذخیره آدرس انجام نشد.';
        return false;
      }

      // Confirm what is *actually* stored, including currently enabled fields.
      final freshResponse = await httpRequest.getAddresses(token: token);
      if (_disposed) return false;
      if (!_validResponse(freshResponse)) {
        _saveErrors[kind] = 'درخواست ذخیره پذیرفته شد، اما بررسی اطلاعات جدید از سرور امکان‌پذیر نیست.';
        return false;
      }

      final newAddresses = AddressesResponseModel.fromJson(Map<String, dynamic>.from(freshResponse as Map)).data;
      addresses = newAddresses;
      AddressSession.save(newAddresses);
      try {
        final count = (newAddresses.billing.hasAddress ? 1 : 0) + (newAddresses.shipping.hasAddress ? 1 : 0);
        await AppCache.setInt('address_count', count);
      } catch (e) {
        AppLog.error('ADDRESS COUNT CACHE ERROR >>> $e');
      }
      return true;
    } on FormatException catch (e, stack) {
      AppLog.error('ADDRESS UPDATE RESPONSE ERROR >>> $e\n$stack');
      _saveErrors[kind] = 'ذخیره به سرور ارسال شد اما پاسخ اطلاعات آدرس قابل تأیید نیست.';
      return false;
    } catch (e, stack) {
      AppLog.error('ADDRESS UPDATE ERROR >>> $e\n$stack');
      _saveErrors[kind] = 'تأیید ذخیره آدرس امکان‌پذیر نبود؛ وضعیت آدرس را مجدداً بررسی کنید.';
      return false;
    } finally {
      _saving.remove(kind);
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class FieldMeta {
  const FieldMeta({required this.keyName, required this.label, required this.icon, this.keyboardType = TextInputType.text});
  final String keyName;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
}
