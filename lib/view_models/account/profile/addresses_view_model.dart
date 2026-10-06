import 'package:flutter/foundation.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/account_session_cache.dart';

enum AddressKind { billing, shipping }

extension AddressKindX on AddressKind {
  String get apiKey => this == AddressKind.billing ? 'billing' : 'shipping';

  String get title => this == AddressKind.billing ? 'صورتحساب' : 'ارسال';
}

class AddressesViewModel extends ChangeNotifier {
  AddressesViewModel({
    required this.token,
    AddressBookModel? initialAddresses,
    this.onUpdated,
    HttpRequest? httpRequest,
  })  : addresses = initialAddresses,
        _httpRequest = httpRequest ?? HttpRequest();

  final String token;
  final HttpRequest _httpRequest;
  final ValueChanged<AddressBookModel>? onUpdated;

  AddressBookModel? addresses;
  bool isLoading = false;
  bool isRefreshing = false;
  bool savingBilling = false;
  bool savingShipping = false;
  String errorMessage = '';
  String saveErrorMessage = '';

  bool saving(AddressKind kind) => kind == AddressKind.billing ? savingBilling : savingShipping;

  CustomerAddressModel? address(AddressKind kind) {
    final model = addresses;
    if (model == null) return null;
    return kind == AddressKind.billing ? model.billing : model.shipping;
  }

  Future<void> load({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;

    if (!refresh && AccountSessionCache.addressesLoaded) {
      addresses = AccountSessionCache.addresses ?? AddressBookModel.empty();
      errorMessage = '';
      notifyListeners();
      return;
    }

    if (addresses == null && !refresh) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = '';
    notifyListeners();

    try {
      final response = await _httpRequest.getAddresses(token: token);
      if (response is! Map) {
        errorMessage = 'دریافت آدرس‌ها انجام نشد.';
        return;
      }

      final map = Map<String, dynamic>.from(response);
      final model = AddressesResponseModel.fromJson(map);
      if (!model.success) {
        errorMessage = model.message.isNotEmpty ? model.message : 'دریافت آدرس‌ها انجام نشد.';
        return;
      }

      addresses = model.data;
      AccountSessionCache.addresses = model.data;
      AccountSessionCache.addressesLoaded = true;
    } catch (e) {
      if (kDebugMode) print('ADDRESSES LOAD ERROR >>>> $e');
      errorMessage = 'دریافت آدرس‌ها انجام نشد. اتصال اینترنت را بررسی کنید.';
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(AddressKind kind, Map<String, String> changes) async {
    if (changes.isEmpty || saving(kind)) return false;

    saveErrorMessage = '';
    _setSaving(kind, true);

    try {
      final response = await _httpRequest.updateAddresses(
        token: token,
        changes: <String, dynamic>{kind.apiKey: changes},
      );

      if (response is! Map) {
        saveErrorMessage = 'ذخیره آدرس انجام نشد.';
        return false;
      }

      final map = Map<String, dynamic>.from(response);
      final success = map.containsKey('success') ? map['success'] == true : (map['status_code'] as int? ?? 200) < 300;
      if (!success) {
        saveErrorMessage = map['message']?.toString().trim().isNotEmpty == true ? map['message'].toString().trim() : 'ذخیره آدرس انجام نشد.';
        return false;
      }

      final parsed = AddressesResponseModel.fromJson(map);
      final payload = _addressPayload(map);
      final current = addresses ?? AddressBookModel.empty();

      if (payload.isNotEmpty) {
        addresses = current.copyWith(
          billing: payload.containsKey('billing') ? parsed.data.billing : current.billing,
          shipping: payload.containsKey('shipping') ? parsed.data.shipping : current.shipping,
        );
      } else {
        addresses = kind == AddressKind.billing
            ? current.copyWith(billing: current.billing.merge(changes))
            : current.copyWith(shipping: current.shipping.merge(changes));
      }

      if (addresses != null) {
        AccountSessionCache.addresses = addresses;
        AccountSessionCache.addressesLoaded = true;
        onUpdated?.call(addresses!);
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('ADDRESS UPDATE ERROR >>>> $e');
      saveErrorMessage = 'ذخیره آدرس انجام نشد. اتصال اینترنت را بررسی کنید.';
      return false;
    } finally {
      _setSaving(kind, false);
    }
  }

  Map<String, dynamic> _addressPayload(Map<String, dynamic> map) {
    final data = map['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final nested = dataMap['addresses'];
      if (nested is Map && (nested.containsKey('billing') || nested.containsKey('shipping'))) {
        return Map<String, dynamic>.from(nested);
      }
      if (dataMap.containsKey('billing') || dataMap.containsKey('shipping')) return dataMap;
    }
    if (map.containsKey('billing') || map.containsKey('shipping')) return map;
    return <String, dynamic>{};
  }

  void _setSaving(AddressKind kind, bool value) {
    if (kind == AddressKind.billing) {
      savingBilling = value;
    } else {
      savingShipping = value;
    }
    notifyListeners();
  }
}
