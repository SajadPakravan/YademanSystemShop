import 'package:flutter/material.dart';
import 'package:yad_sys/models/address_model.dart';
import 'package:yad_sys/screens/account/profile/addresses/billing_screen.dart';
import 'package:yad_sys/screens/account/profile/addresses/shipping_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/view_models/account/profile/address/addresses_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/error_connection_widget.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AddressesView extends StatelessWidget {
  const AddressesView({super.key, required this.viewModel});

  final AddressesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (viewModel.addresses == null) {
      if (viewModel.isLoading) return const Loading();
      return ErrorConnectionWidget(
        errorMessage: viewModel.errorMessage.isNotEmpty ? viewModel.errorMessage : 'دریافت آدرس‌ها انجام نشد.',
        onPressed: () => viewModel.load(),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(centerTitle: true, title: const AppText.titleMedium('آدرس‌ها', fontWeight: FontWeight.w700)),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                addressPreviewCard(context, viewModel.billing, BillingScreen(addressVM: viewModel)),
                addressPreviewCard(context, viewModel.shipping, ShippingScreen(addressesViewModel: viewModel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addressPreviewCard(BuildContext context, AddressFieldsModel? kind, dynamic page) {
    final colors = context.appColors;
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.all(r.space(10)),
      margin: EdgeInsets.all(r.space(10)),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(r.space(15)),
      ),
      child: Column(
        spacing: r.space(10),
        children: [
          AppText.titleMedium(kind == viewModel.billing ? 'آدرس صورتحساب' : 'آدرس ارسال'),
          kind == null || kind.isEmpty
              ? AppButton(
                  onPressed: () async {
                    final address = await rightToPage(page);
                  },
                  label: kind == viewModel.billing ? 'آدرس صورتحساب را ثبت کنید' : 'آدرس ارسال را ثبت کنید',
                )
              : kind.hasAddress
              ? addressKindPreview(context, kind, page)
              : AppButton(
                  onPressed: () async {
                    final address = await rightToPage(page);
                  },
                  label: kind == viewModel.billing ? 'آدرس صورتحساب را تکمیل کنید' : 'آدرس ارسال را تکمیل کنید',
                ),
        ],
      ),
    );
  }

  Widget addressKindPreview(BuildContext context, AddressFieldsModel kind, dynamic page) {
    final colors = context.appColors;
    final r = context.responsive;
    final values = kind.addressValues;

    return Column(
      spacing: 10,
      children: [
        AppText.titleSmall('مشخصات گیرنده:'),
        AppText.bodyMedium('نام: ${values['first_name']!} ${values['last_name']!}'),
        AppText.bodyMedium('شماره تماس: ${values['phone']}'),
        if (values.containsKey('email') && values['email']!.isNotEmpty) AppText.bodyMedium('ایمیل: ${values['email']}'),
        AppText.bodyMedium('آدرس:'),
        Row(
          spacing: 5,
          children: [
            AppText.bodyMedium('استان ${viewModel.state(values['state']!)}'),
            AppText.bodyMedium('،'),
            AppText.bodyMedium('شهرستان ${values['city']}'),
          ],
        ),
        AppText.bodyMedium('منطقه و خیابان:'),
        AppText.bodyMedium(values['address_1']!),
        AppText.bodyMedium('کوچه و پلاک:'),
        AppText.bodyMedium(values['address_2']!),
        AppText.bodyMedium('کد پستی: ${values['postcode']}'),
        SizedBox(height: 10),
        AppButton(
          label: 'ویرایش',
          onPressed: () async {
            final address = await rightToPage(page);
          },
        ),
      ],
    );
  }
}
