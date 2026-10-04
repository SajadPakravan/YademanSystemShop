import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AddressesView extends StatelessWidget {
  const AddressesView({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DefaultTabController(
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
        body: TabBarView(
          children: [
            _BillingForm(address: customer.billing),
            _ShippingForm(address: customer.shipping),
          ],
        ),
      ),
    );
  }
}

class _BillingForm extends StatefulWidget {
  const _BillingForm({required this.address});

  final Billing address;

  @override
  State<_BillingForm> createState() => _BillingFormState();
}

class _BillingFormState extends State<_BillingForm> {
  late final List<TextEditingController> c;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    c = [
      a.firstName,
      a.lastName,
      a.company,
      a.country,
      a.state,
      a.city,
      a.address1,
      a.address2,
      a.postcode,
      a.email,
      a.phone,
    ].map((value) => TextEditingController(text: value)).toList();
  }

  @override
  void dispose() {
    for (final item in c) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AddressForm(
    controllers: c,
    labels: const ['نام', 'نام خانوادگی', 'شرکت', 'کشور', 'استان', 'شهر', 'آدرس اصلی', 'آدرس تکمیلی', 'کدپستی', 'ایمیل', 'شماره تماس'],
    icons: const [
      Icons.person_outline,
      Icons.person_outline,
      Icons.business_outlined,
      Icons.public,
      Icons.map_outlined,
      Icons.location_city,
      Icons.location_on_outlined,
      Icons.add_location_alt_outlined,
      Icons.markunread_mailbox_outlined,
      Icons.email_outlined,
      Icons.phone_outlined,
    ],
  );
}

class _ShippingForm extends StatefulWidget {
  const _ShippingForm({required this.address});

  final Shipping address;

  @override
  State<_ShippingForm> createState() => _ShippingFormState();
}

class _ShippingFormState extends State<_ShippingForm> {
  late final List<TextEditingController> c;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    c = [
      a.firstName,
      a.lastName,
      a.company,
      a.country,
      a.state,
      a.city,
      a.address1,
      a.address2,
      a.postcode,
      a.phone,
    ].map((value) => TextEditingController(text: value)).toList();
  }

  @override
  void dispose() {
    for (final item in c) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AddressForm(
    controllers: c,
    labels: const ['نام', 'نام خانوادگی', 'شرکت', 'کشور', 'استان', 'شهر', 'آدرس اصلی', 'آدرس تکمیلی', 'کدپستی', 'شماره تماس'],
    icons: const [
      Icons.person_outline,
      Icons.person_outline,
      Icons.business_outlined,
      Icons.public,
      Icons.map_outlined,
      Icons.location_city,
      Icons.location_on_outlined,
      Icons.add_location_alt_outlined,
      Icons.markunread_mailbox_outlined,
      Icons.phone_outlined,
    ],
  );
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({required this.controllers, required this.labels, required this.icons});

  final List<TextEditingController> controllers;
  final List<String> labels;
  final List<IconData> icons;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final List<String> initialValues;

  @override
  void initState() {
    super.initState();
    initialValues = widget.controllers.map((e) => e.text).toList(growable: false);
  }

  bool get dirty {
    for (var i = 0; i < widget.controllers.length; i++) {
      if (widget.controllers[i].text.trim() != initialValues[i]) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.controllers.length; i++) ...[
            AppText.labelMedium(widget.labels[i], color: context.appColors.textSecondary, fontWeight: FontWeight.w700),
            SizedBox(height: r.space(6)),
            AppTextField(
              controller: widget.controllers[i],
              hint: widget.labels[i],
              icon: widget.icons[i],
              keyboardType: widget.labels[i] == 'شماره تماس'
                  ? TextInputType.phone
                  : widget.labels[i] == 'ایمیل'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: r.space(12)),
          ],
          AppButton(
            label: 'ثبت آدرس',
            enabled: dirty,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API ویرایش و افزودن آدرس هنوز فعال نشده است.'))),
          ),
        ],
      ),
    );
  }
}
