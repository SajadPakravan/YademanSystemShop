import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_input_formatter.dart';
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
    final colors = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(centerTitle: true, title: const AppText.titleMedium('آدرس صورتحساب', fontWeight: FontWeight.w700)),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.info.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.info, size: 22),
                  Expanded(
                    child: AppText.bodyMedium(
                      'این آدرس برای ثبت مشخصات خریدار و صدور صورتحساب سفارش استفاده می‌شود. اگر کالا را در محل دیگری دریافت می‌کنید، آدرس ارسال را جداگانه ثبت کنید.',
                      color: colors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (int index = 0; index < fields.length; index++) ...[buildField(context, fields[index], index == fields.length - 1), const SizedBox(height: 15)],
            const SizedBox(height: 10),
            if (viewModel.saveMessage.isNotEmpty) ...[
              AppText.bodySmall(viewModel.saveMessage, color: viewModel.saved ? colors.success : AppColors.error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
            AppButton(label: 'ثبت آدرس', icon: Icons.save_outlined, loading: viewModel.isSaving, onPressed: () => viewModel.confirm()),
            const SizedBox(height: 10),
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
        onChanged: (_) => viewModel.fieldEdited(key),
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
        emptyMessage: 'شهری پیدا نشد. اول استان را انتخاب کنید',
        options: viewModel.cities,
        errorText: error,
        onSelected: viewModel.selectCity,
        onChanged: (_) => viewModel.fieldEdited(key),
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
      inputFormatters: key == 'first_name' || key == 'last_name'
          ? AppInputFormatter.formatters(AppInputType.sPersianLetters)
          : key == 'address_1' || key == 'address_2'
          ? AppInputFormatter.formatters(AppInputType.snvPersianLetters)
          : key == 'phone'
          ? AppInputFormatter.formatters(AppInputType.numbers, maxLength: 11)
          : key == 'postcode'
          ? AppInputFormatter.formatters(AppInputType.numbers, maxLength: 10)
          : null,
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
