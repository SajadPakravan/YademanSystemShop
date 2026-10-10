import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile/address_form_view_model.dart';
import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/forms/location_combo.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

/// Presentational form reused by two independently-owned tab view models.
class AddressFormView extends StatelessWidget {
  const AddressFormView({super.key, required this.viewModel});
  final AddressFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final fields = viewModel.fields;

    if (fields.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(r.pageHorizontalPadding),
          child: AppText.bodySmall('در حال حاضر هیچ فیلد فعالی برای این آدرس از سمت سرور دریافت نشده است.', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView(
      key: PageStorageKey<String>('address_form_${viewModel.kind.apiKey}'),
      padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(30)),
      children: [
        for (var index = 0; index < fields.length; index++) ...[
          if (fields[index].keyName == 'state' && viewModel.provinces.isNotEmpty)
            LocationCombo(
              key: ValueKey('${viewModel.kind.apiKey}_state_combo'),
              title: 'استان',
              hint: 'نام استان را جستجو یا انتخاب کنید',
              icon: Icons.map_outlined,
              emptyMessage: 'استانی پیدا نشد.',
              code: viewModel.controllers['state']!.text,
              list: viewModel.provinces,
              errorText: viewModel.errors['state'],
              onChanged: (code) => viewModel.locationSelected('state', code),
            )
          else if (fields[index].keyName == 'city' && viewModel.cities.isNotEmpty)
            LocationCombo(
              key: ValueKey('${viewModel.kind.apiKey}_city_combo'),
              title: 'شهر',
              hint: 'نام شهر را جستجو یا انتخاب کنید',
              icon: Icons.location_city_outlined,
              emptyMessage: 'شهری پیدا نشد.',
              code: viewModel.controllers['city']!.text,
              list: viewModel.cities,
              errorText: viewModel.errors['city'],
              onChanged: (code) => viewModel.locationSelected('city', code),
            )
          else
            AppTextField(
              key: ValueKey('${viewModel.kind.apiKey}_${fields[index].keyName}_text'),
              controller: viewModel.controllers[fields[index].keyName]!,
              title: fields[index].label,
              hint: fields[index].label,
              icon: fields[index].icon,
              keyboardType: fields[index].keyboardType,
              textInputAction: index == fields.length - 1 ? TextInputAction.done : TextInputAction.next,
              errorText: viewModel.errors[fields[index].keyName],
              onChanged: (_) => viewModel.fieldEdited(fields[index].keyName),
              onSubmitted: (_) {
                if (index == fields.length - 1) viewModel.submit(context);
              },
            ),
          if (index != fields.length - 1) SizedBox(height: r.space(14)),
        ],
        SizedBox(height: r.space(20)),
        if (viewModel.saveErrorMessage.isNotEmpty) ...[
          AppText.bodySmall(viewModel.saveErrorMessage, color: AppColors.error, textAlign: TextAlign.center),
          SizedBox(height: r.space(10)),
        ],
        AppButton(
          label: 'ثبت تغییرات آدرس',
          icon: Icons.save_outlined,
          loading: viewModel.isSaving,
          enabled: viewModel.fieldChanged,
          onPressed: () => viewModel.submit(context),
        ),
      ],
    );
  }
}
