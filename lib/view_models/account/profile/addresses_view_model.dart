import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/sessions/address_session.dart';

/// نوع آدرس مورد ویرایش برای تعیین کلید ارسال API.
enum AddressKind { billing, shipping }

/// کلید JSON و عنوان هر تب آدرس.
extension AddressKindX on AddressKind {
  /// کلید موردنیاز سرور برای به‌روزرسانی جزئی.
  String get apiKey => this == AddressKind.billing ? 'billing' : 'shipping';
  /// عنوان نمایشی تب.
  String get title => this == AddressKind.billing ? 'صورتحساب' : 'ارسال';
}

/// دریافت و ویرایش آدرس‌های مشتری با حفظ اطلاعات استان‌ها.
class AddressesViewModel extends ChangeNotifier {
  /// تزریق توکن و اطلاعات اختیاری پیشین بدون اجبار به کش آدرس.
  AddressesViewModel({required this.token, AddressBookModel? initialAddresses, HttpRequest? httpRequest})
    : addresses = initialAddresses, httpRequest = httpRequest ?? HttpRequest();

  final HttpRequest httpRequest;
  final String token;
  AddressBookModel? addresses;
  bool isLoading = false, isRefreshing = false;
  bool savingBilling = false, savingShipping = false;
  String errorMessage = '', saveErrorMessage = '';
  bool _disposed = false;

  /// وضعیت ذخیره شدن آدرس انتخابی.
  bool saving(AddressKind kind) => kind == AddressKind.billing ? savingBilling : savingShipping;

  /// بازیابی داده‌های یک تب آدرس.
  CustomerAddressModel? address(AddressKind kind) {
    final model = addresses;
    if (model == null) return null;
    return kind == AddressKind.billing ? model.billing : model.shipping;
  }

  /// خواندن تازه آدرس‌ها و فهرست استان‌ها هنگام باز شدن صفحه.
  Future<void> load({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;
    isLoading = addresses == null;
    isRefreshing = !isLoading;
    errorMessage = '';
    notifyListeners();
    try {
      final response = await httpRequest.getAddresses(token: token);
      if (_disposed) return;
      if (response is! Map || response['success'] != true) {
        errorMessage = response is Map ? response['message']?.toString() ?? 'دریافت آدرس‌ها انجام نشد.' : 'دریافت آدرس‌ها انجام نشد.';
        return;
      }
      addresses = AddressesResponseModel.fromJson(Map<String, dynamic>.from(response)).data;
      AddressSession.save(addresses!);
    } catch (e) {
      if (kDebugMode) print('ADDRESSES LOAD ERROR >>> $e');
      errorMessage = 'دریافت آدرس‌ها انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally { isLoading = isRefreshing = false; notifyListeners(); }
  }

  /// PUT تغییرات آدرس انتخاب‌شده؛ پاسخ ناقص باعث حذف آدرس دیگر نمی‌شود.
  Future<bool> updateAddress(AddressKind kind, Map<String, String> changes) async {
    if (changes.isEmpty || saving(kind) || addresses == null) return false;
    saveErrorMessage = '';
    _setSaving(kind, true);
    try {
      final response = await httpRequest.updateAddresses(token: token, changes: <String, dynamic>{kind.apiKey: changes});
      if (_disposed) return false;
      if (response is! Map || response['success'] != true) {
        saveErrorMessage = response is Map && response['message'] != null ? response['message'].toString() : 'ذخیره آدرس انجام نشد.';
        return false;
      }
      final current = addresses!;
      final payload = _addressPayload(Map<String, dynamic>.from(response));
      // فیلدهای همان تب، حتی با برگشت ناقص JSON، با مقادیر تأییدشده ادغام می‌شوند.
      CustomerAddressModel merged(AddressKind itemKind) {
        final previous = itemKind == AddressKind.billing ? current.billing : current.shipping;
        final changed = itemKind == kind ? changes : const <String, String>{};
        final returned = payload[itemKind.apiKey];
        final returnedFields = returned is Map ? Map<String, dynamic>.from(returned) : const <String, dynamic>{};
        final fromServer = <String, String>{for (final entry in returnedFields.entries) if (CustomerAddressModel.standardFields.contains(entry.key)) entry.key: entry.value?.toString() ?? ''};
        return previous.merge({...changed, ...fromServer});
      }
      addresses = current.copyWith(billing: merged(AddressKind.billing), shipping: merged(AddressKind.shipping));
      AddressSession.save(addresses!);
      return true;
    } catch (e) {
      if (kDebugMode) print('ADDRESS UPDATE ERROR >>> $e');
      saveErrorMessage = 'ذخیره آدرس انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally { _setSaving(kind, false); }
  }

  /// جداکردن billing/shipping از یکی از ساختارهای متداول پاسخ PUT.
  Map<String, dynamic> _addressPayload(Map<String, dynamic> map) {
    final data = map['data'];
    if (data is Map) {
      final nested = data['addresses'];
      if (nested is Map && (nested.containsKey('billing') || nested.containsKey('shipping'))) return Map<String, dynamic>.from(nested);
      if (data.containsKey('billing') || data.containsKey('shipping')) return Map<String, dynamic>.from(data);
    }
    if (map.containsKey('billing') || map.containsKey('shipping')) return map;
    return <String, dynamic>{};
  }

  /// بروزرسانی نشانگر ذخیره آدرس و اطلاع به رابط کاربری.
  void _setSaving(AddressKind kind, bool value) {
    if (kind == AddressKind.billing) { savingBilling = value; } else { savingShipping = value; }
    notifyListeners();
  }

  /// جلوگیری از اعلان تغییرات بعد از بسته‌شدن صفحه.
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }

  /// پایان چرخه حیات مدل.
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
