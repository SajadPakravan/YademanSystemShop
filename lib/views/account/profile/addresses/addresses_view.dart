import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/error_connection_widget.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AddressesView extends StatelessWidget {
  const AddressesView({super.key, required this.viewModel});

  final AddressesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final addresses = viewModel.addresses;

    if (viewModel.isLoading && addresses == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const SafeArea(child: Loading()),
      );
    }

    if (addresses == null) {
      return ErrorConnectionWidget(
        errorMessage: viewModel.errorMessage.isNotEmpty ? viewModel.errorMessage : 'دریافت آدرس‌ها انجام نشد.',
        onPressed: () => viewModel.load(refresh: true),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            centerTitle: true,
            title: const AppText.titleMedium('آدرس‌ها', fontWeight: FontWeight.w700),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'صورتحساب'),
                Tab(text: 'ارسال'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (viewModel.isRefreshing) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: TabBarView(
                  children: [
                    _AddressForm(key: const ValueKey('billing_address_form'), kind: AddressKind.billing, address: addresses.billing, viewModel: viewModel),
                    _AddressForm(key: const ValueKey('shipping_address_form'), kind: AddressKind.shipping, address: addresses.shipping, viewModel: viewModel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressFieldMeta {
  const _AddressFieldMeta({required this.keyName, required this.label, required this.icon, this.keyboardType = TextInputType.text});

  final String keyName;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
}

const List<_AddressFieldMeta> _fieldDefinitions = <_AddressFieldMeta>[
  _AddressFieldMeta(keyName: 'first_name', label: 'نام', icon: Icons.person_outline_rounded),
  _AddressFieldMeta(keyName: 'last_name', label: 'نام خانوادگی', icon: Icons.badge_outlined),
  _AddressFieldMeta(keyName: 'company', label: 'شرکت', icon: Icons.business_outlined),
  _AddressFieldMeta(keyName: 'country', label: 'کشور', icon: Icons.public_rounded),
  _AddressFieldMeta(keyName: 'state', label: 'استان', icon: Icons.map_outlined),
  _AddressFieldMeta(keyName: 'city', label: 'شهر', icon: Icons.location_city_outlined),
  _AddressFieldMeta(keyName: 'address_1', label: 'آدرس اصلی', icon: Icons.location_on_outlined),
  _AddressFieldMeta(keyName: 'address_2', label: 'ادامه آدرس', icon: Icons.add_location_alt_outlined),
  _AddressFieldMeta(keyName: 'postcode', label: 'کدپستی', icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
  _AddressFieldMeta(keyName: 'email', label: 'ایمیل', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
  _AddressFieldMeta(keyName: 'phone', label: 'شماره تماس', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
];

class _AddressForm extends StatefulWidget {
  const _AddressForm({super.key, required this.kind, required this.address, required this.viewModel});

  final AddressKind kind;
  final CustomerAddressModel address;
  final AddressesViewModel viewModel;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final Map<String, TextEditingController> _controllers;
  late Map<String, String> _initialValues;
  final Map<String, String> _errors = <String, String>{};

  List<_AddressFieldMeta> get _visibleFields {
    return _fieldDefinitions.where((field) => widget.address.hasField(field.keyName)).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _createControllers();
  }

  @override
  void didUpdateWidget(covariant _AddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.address, widget.address)) return;

    final visibleKeys = _visibleFields.map((field) => field.keyName).toSet();
    final removedKeys = _controllers.keys.where((key) => !visibleKeys.contains(key)).toList(growable: false);
    for (final key in removedKeys) {
      _controllers.remove(key)?.dispose();
    }

    for (final field in _visibleFields) {
      final value = widget.address.value(field.keyName);
      final controller = _controllers[field.keyName];
      if (controller == null) {
        _controllers[field.keyName] = TextEditingController(text: value);
      } else {
        controller.text = value;
      }
    }

    _initialValues = <String, String>{for (final entry in _controllers.entries) entry.key: entry.value.text.trim()};
    _errors.clear();
  }

  void _createControllers() {
    _controllers = <String, TextEditingController>{
      for (final field in _visibleFields) field.keyName: TextEditingController(text: widget.address.value(field.keyName)),
    };
    _initialValues = <String, String>{for (final entry in _controllers.entries) entry.key: entry.value.text.trim()};
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _dirty {
    for (final entry in _controllers.entries) {
      if (entry.value.text.trim() != (_initialValues[entry.key] ?? '')) return true;
    }
    return false;
  }

  Map<String, String> get _changes {
    final result = <String, String>{};
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value != (_initialValues[entry.key] ?? '')) result[entry.key] = value;
    }
    return result;
  }

  bool _validate() {
    _errors.clear();

    final email = _controllers['email']?.text.trim() ?? '';
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$");
      if (!emailRegex.hasMatch(email)) _errors['email'] = 'ایمیل وارد شده معتبر نیست.';
    }

    final phone = (_controllers['phone']?.text ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (phone.isNotEmpty) {
      final iranPhone = RegExp(r'^(?:0\d{10}|\+98\d{10}|98\d{10})$');
      if (!iranPhone.hasMatch(phone)) _errors['phone'] = 'شماره تماس وارد شده معتبر نیست.';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _submit(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_dirty || !_validate()) return;

    final success = await widget.viewModel.updateAddress(widget.kind, _changes);
    if (!mounted) return;

    if (!success) {
      SnackBarView.show(context, widget.viewModel.saveErrorMessage.isNotEmpty ? widget.viewModel.saveErrorMessage : 'ذخیره آدرس انجام نشد.');
      return;
    }

    final updated = widget.viewModel.address(widget.kind);
    if (updated != null) {
      for (final entry in _controllers.entries) {
        entry.value.text = updated.value(entry.key);
      }
    }

    _initialValues = <String, String>{for (final entry in _controllers.entries) entry.key: entry.value.text.trim()};
    _errors.clear();
    setState(() {});
    SnackBarView.show(context, 'آدرس با موفقیت ذخیره شد.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final visibleFields = _visibleFields;

    if (visibleFields.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => widget.viewModel.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(r.pageHorizontalPadding),
          children: [
            SizedBox(height: r.percentHeight(0.18, min: 110, max: 180)),
            Icon(Icons.location_off_outlined, size: r.icon(62), color: colors.textMuted),
            SizedBox(height: r.space(12)),
            AppText.bodyMedium(
              'در حال حاضر فیلدی برای آدرس ${widget.kind.title} از سمت سرور فعال نیست.',
              textAlign: TextAlign.center,
              color: colors.textSecondary,
              height: 1.7,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.viewModel.load(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(30)),
        children: [
          for (var index = 0; index < visibleFields.length; index++) ...[
            AppTextField(
              controller: _controllers[visibleFields[index].keyName]!,
              title: visibleFields[index].label,
              hint: visibleFields[index].label,
              icon: visibleFields[index].icon,
              keyboardType: visibleFields[index].keyboardType,
              textInputAction: index == visibleFields.length - 1 ? TextInputAction.done : TextInputAction.next,
              errorText: _errors[visibleFields[index].keyName],
              onChanged: (_) {
                if (_errors.remove(visibleFields[index].keyName) != null) setState(() {});
                setState(() {});
              },
              onSubmitted: (_) {
                if (index == visibleFields.length - 1) _submit(context);
              },
            ),
            if (index != visibleFields.length - 1) SizedBox(height: r.space(14)),
          ],
          SizedBox(height: r.space(20)),
          if (widget.viewModel.saveErrorMessage.isNotEmpty) ...[
            AppText.bodySmall(widget.viewModel.saveErrorMessage, color: AppColors.error, textAlign: TextAlign.center),
            SizedBox(height: r.space(10)),
          ],
          AppButton(
            label: 'ثبت تغییرات آدرس',
            icon: Icons.save_outlined,
            loading: widget.viewModel.saving(widget.kind),
            enabled: _dirty,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }
}
