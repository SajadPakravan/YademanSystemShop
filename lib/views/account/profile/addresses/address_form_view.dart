// import 'package:flutter/material.dart';
// import 'package:yad_sys/models/address_model.dart';
// import 'package:yad_sys/tools/app_colors.dart';
// import 'package:yad_sys/tools/app_dimension.dart';
// import 'package:yad_sys/view_models/account/profile/addresses_view_model.dart';
// import 'package:yad_sys/widgets/buttons/app_button.dart';
// import 'package:yad_sys/widgets/forms/app_text_field.dart';
// import 'package:yad_sys/widgets/forms/location_combo.dart';
// import 'package:yad_sys/widgets/text_views/app_text.dart';
//
// class AddressFormView extends StatelessWidget {
//   const AddressFormView({super.key, required this.viewModel, required this.kind});
//
//   final AddressesViewModel viewModel;
//
//   /// ساخت فیلد متناسب با نوع داده، بدون تکرار فرم‌های صورتحساب و ارسال.
//   Widget _field(BuildContext context, FieldMeta field, bool isLast) {
//     final key = field.keyName;
//     if (key == 'state') {
//       return LocationCombo<Province>(
//         key: ValueKey('${kind.apiKey}_state'),
//         controller: viewModel.controllerFor(kind, key),
//         focusNode: viewModel.focusFor(kind, key),
//         options: viewModel.provinces,
//         labelOf: (province) => province.name,
//         onSelected: (province) => viewModel.selectProvince(kind, province),
//         onTextEdited: (_) => viewModel.fieldEdited(kind, key),
//         title: field.label,
//         hint: 'استان را جستجو و انتخاب کنید',
//         icon: field.icon,
//         emptyMessage: 'استانی پیدا نشد.',
//         errorText: viewModel.errorFor(kind, key),
//       );
//     }
//     if (key == 'city') {
//       return LocationCombo<City>(
//         key: ValueKey('${kind.apiKey}_city'),
//         controller: viewModel.controllerFor(kind, key),
//         focusNode: viewModel.focusFor(kind, key),
//         options: viewModel.citiesFor(kind),
//         labelOf: (city) => city.name,
//         onSelected: (city) => viewModel.selectCity(kind, city),
//         onTextEdited: (_) => viewModel.fieldEdited(kind, key),
//         title: field.label,
//         hint: 'شهر را جستجو و انتخاب کنید',
//         icon: field.icon,
//         emptyMessage: 'ابتدا استان را انتخاب کنید یا نام شهر را جستجو کنید.',
//         errorText: viewModel.errorFor(kind, key),
//       );
//     }
//     return AppTextField(
//       key: ValueKey('${kind.apiKey}_$key'),
//       controller: viewModel.controllerFor(kind, key),
//       title: field.label,
//       hint: field.label,
//       icon: field.icon,
//       keyboardType: field.keyboardType,
//       textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
//       errorText: viewModel.errorFor(kind, key),
//       onChanged: (_) => viewModel.fieldEdited(kind, key),
//       onSubmitted: (_) {
//         if (isLast) viewModel.submit(kind, context);
//       },
//     );
//   }
//
//   /// رندر فرم با کلید مستقل برای حفظ اسکرول هر تب.
//   @override
//   Widget build(BuildContext context) {
//     final r = context.responsive;
//     final fields = viewModel.fieldsFor(kind);
//     return ListView(
//       key: PageStorageKey<String>('address_form_${kind.apiKey}'),
//       padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(30)),
//       children: [
//         for (var i = 0; i < fields.length; i++) ...[
//           _field(context, fields[i], i == fields.length - 1),
//           if (i != fields.length - 1) SizedBox(height: r.space(14)),
//         ],
//         SizedBox(height: r.space(20)),
//         if (viewModel.saveErrorFor(kind).isNotEmpty) ...[
//           AppText.bodySmall(viewModel.saveErrorFor(kind), color: AppColors.error, textAlign: TextAlign.center),
//           SizedBox(height: r.space(10)),
//         ],
//         AppButton(
//           label: 'ثبت تغییرات آدرس',
//           icon: Icons.save_outlined,
//           loading: viewModel.saving(kind),
//           enabled: viewModel.changed(kind) && !viewModel.anySaving && !viewModel.isLoading,
//           onPressed: () => viewModel.submit(kind, context),
//         ),
//       ],
//     );
//   }
// }
