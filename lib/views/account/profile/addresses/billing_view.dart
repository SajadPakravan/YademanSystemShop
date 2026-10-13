import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/view_models/account/profile/address/billing_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/forms/location_combo.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class BillingView extends StatelessWidget {
  const BillingView({super.key, required this.viewModel});

  final BillingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final fields = viewModel.fields;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.appColors.surface,
        appBar: AppBar(centerTitle: true, title: const AppText.titleMedium('آدرس‌ صورتحساب', fontWeight: FontWeight.w700)),
        body: ListView(
          padding: EdgeInsets.all(15),
          children: [
            for (int index = 0; index < fields.length; index++) ...[buildField(context, fields[index], index == fields.length - 1), SizedBox(height: 15)],
            SizedBox(height: 10),
            AppButton(label: 'ثبت آدرس', onPressed: () {}),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildField(BuildContext context, FieldMeta field, bool isLast) {
    final key = field.keyName;
    final controller = viewModel.fieldCtrl[key]!;
    final error = viewModel.fieldErrors[key];

    if (key == 'state') {
      return LocationCombo<Province>(
        key: const ValueKey('billing_state'),
        controller: controller,
        focusNode: viewModel.fieldFocus['state']!,
        title: field.label,
        hint: 'نام استان را جستجو یا انتخاب کنید',
        icon: field.icon,
        emptyMessage: 'استانی پیدا نشد',
        options: viewModel.provinces,
        errorText: error,
        onSelected: viewModel.selectProvince,
        labelOf: (province) => province.name,
      );
    }

    if (key == 'city') {
      return LocationCombo<String>(
        key: const ValueKey('billing_city'),
        controller: controller,
        focusNode: viewModel.fieldFocus['city']!,
        title: field.label,
        hint: 'نام شهر را جستجو یا انتخاب کنید',
        icon: field.icon,
        emptyMessage: 'شهری پیدا نشد',
        options: viewModel.cities,
        errorText: error,
        onSelected: viewModel.selectCity,
        labelOf: (city) => city,
      );
    }

    return AppTextField(
      key: ValueKey('billing_$key'),
      controller: controller,
      title: field.label,
      hint: field.label,
      icon: field.icon,
      keyboardType: field.keyboardType,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      errorText: error,
      onChanged: (_) => viewModel.fieldEdited(key),
      onSubmitted: (_) {
        if (isLast) {
          FocusScope.of(context).unfocus();
        } else {
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }
}
