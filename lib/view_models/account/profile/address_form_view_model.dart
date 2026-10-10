import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';

/// Independent, reusable form behaviour; concrete billing/shipping models
/// each own their own controllers, errors and original values.
abstract class AddressFormViewModel extends ChangeNotifier {
  AddressFormViewModel({required this.addressesViewModel, required this.kind}) {
    _synchronize(addressesViewModel.address(kind), preserveEdits: false);
    addressesViewModel.addListener(_onSharedAddressChanged);
  }

  final AddressesViewModel addressesViewModel;
  final AddressKind kind;
  final Map<String, TextEditingController> controllers = <String, TextEditingController>{};
  final Map<String, String> initialValues = <String, String>{};
  final Map<String, String> errors = <String, String>{};
  List<FieldMeta> fields = const <FieldMeta>[];
  AddressFieldsModel? _snapshot;
  bool _disposed = false;
  bool _submitting = false;
  bool _syncScheduled = false;

  bool get isSaving => _submitting || addressesViewModel.anySaving || addressesViewModel.isRefreshing || addressesViewModel.isLoading;
  String get saveErrorMessage => addressesViewModel.saveErrorFor(kind);
  List<LocationOptions> get provinces => addressesViewModel.provinces;
  List<LocationOptions> get cities => addressesViewModel.citiesFor(controllers['state']?.text.trim() ?? '');

  bool get fieldChanged => changes.isNotEmpty;

  Map<String, String> get changes {
    final values = <String, String>{};
    for (final entry in controllers.entries) {
      final value = entry.value.text.trim();
      if (value != (initialValues[entry.key] ?? '')) values[entry.key] = value;
    }
    return values;
  }

  void fieldEdited(String key) {
    errors.remove(key);
    addressesViewModel.clearSaveError(kind);
    notifyListeners();
  }

  void locationSelected(String key, String code) {
    final controller = controllers[key];
    if (controller == null) return;
    final oldCode = controller.text;
    if (oldCode != code) {
      controller.text = code;
      // An old city is never valid after changing/clearing the province.
      if (key == 'state') {
        controllers['city']?.clear();
        errors.remove('city');
      }
    }
    errors.remove(key);
    addressesViewModel.clearSaveError(kind);
    notifyListeners();
  }

  void _onSharedAddressChanged() {
    if (_disposed || _submitting) return;
    final model = addressesViewModel.address(kind);
    if (model == null || identical(model, _snapshot) || _syncScheduled) return;
    _syncScheduled = true;
    // Do not mutate TextField controllers while a TabBarView is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (_disposed) return;
      final latest = addressesViewModel.address(kind);
      if (latest != null && !identical(latest, _snapshot)) {
        _synchronize(latest, preserveEdits: true);
        notifyListeners();
      }
    });
  }

  void _synchronize(AddressFieldsModel? model, {required bool preserveEdits}) {
    if (model == null) return;
    _snapshot = model;
    fields = addressesViewModel.visibleFields(model);
    final visibleKeys = fields.map((field) => field.keyName).toSet();

    for (final key in controllers.keys.toList(growable: false)) {
      if (visibleKeys.contains(key)) continue;
      final oldController = controllers.remove(key);
      initialValues.remove(key);
      errors.remove(key);
      // The previous widget subtree may still reference the controller
      // until the end of this frame.
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => oldController.dispose());
      }
    }

    for (final field in fields) {
      final key = field.keyName;
      final serverValue = model.value(key);
      final controller = controllers[key];
      if (controller == null) {
        controllers[key] = TextEditingController(text: serverValue);
      } else {
        final edited = controller.text.trim() != (initialValues[key] ?? '');
        if ((!preserveEdits || !edited) && controller.text != serverValue) {
          controller.value = TextEditingValue(
            text: serverValue,
            selection: TextSelection.collapsed(offset: serverValue.length),
          );
        }
      }
      // A fresh server snapshot is always the comparison baseline.
      initialValues[key] = serverValue.trim();
      if (controllers[key]!.text.trim() == initialValues[key]) errors.remove(key);
    }
    if (!preserveEdits) errors.clear();
  }

  bool _validate() {
    errors.clear();
    final email = controllers['email']?.text.trim() ?? '';
    if (email.isNotEmpty) {
      final regex = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$");
      if (!regex.hasMatch(email)) errors['email'] = 'ایمیل وارد شده معتبر نیست.';
    }
    final phone = (controllers['phone']?.text ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (phone.isNotEmpty) {
      final iranPhone = RegExp(r'^(?:0\d{10}|\+98\d{10}|98\d{10})$');
      if (!iranPhone.hasMatch(phone)) errors['phone'] = 'شماره تماس وارد شده معتبر نیست.';
    }
    final state = controllers['state']?.text.trim() ?? '';
    if (state.isNotEmpty && state != initialValues['state'] && provinces.isNotEmpty && !provinces.any((item) => item.code == state)) {
      errors['state'] = 'لطفاً استان را از فهرست انتخاب کنید.';
    }
    final city = controllers['city']?.text.trim() ?? '';
    if (city.isNotEmpty && city != initialValues['city'] && cities.isNotEmpty && !cities.any((item) => item.code == city)) {
      errors['city'] = 'لطفاً شهر را از فهرست انتخاب کنید.';
    }
    notifyListeners();
    return errors.isEmpty;
  }

  Future<void> submit(BuildContext context) async {
    if (_disposed || isSaving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_validate() || !fieldChanged) return;

    final changed = changes;
    _submitting = true;
    notifyListeners();
    try {
      final success = await addressesViewModel.updateAddress(kind, changed);
      if (_disposed) return;
      if (!success) {
        if (context.mounted) {
          SnackBarView.show(context, saveErrorMessage.isNotEmpty ? saveErrorMessage : 'تأیید ذخیره آدرس امکان‌پذیر نبود.');
        }
        return;
      }
      _synchronize(addressesViewModel.address(kind), preserveEdits: false);
      if (context.mounted) SnackBarView.show(context, 'آدرس با موفقیت ذخیره شد.');
    } finally {
      _submitting = false;
      _onSharedAddressChanged();
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
    addressesViewModel.removeListener(_onSharedAddressChanged);
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    initialValues.clear();
    errors.clear();
    super.dispose();
  }
}
