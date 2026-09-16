import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  HttpRequest httpRequest = HttpRequest();
  AppCache cache = AppCache();
  CustomerModel customer = CustomerModel();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController reNewPassword = TextEditingController();

  Future<void> profileChanged(bool value) async => await cache.setBool('profileChanged', value);

  @override
  void initState() {
    super.initState();
    profileChanged(false);
    setState(() => customer = Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'مشخصات فردی'),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  field(controller: currentPassword, hint: 'رمز عبور فعلی'),
                  field(controller: newPassword, hint: 'رمز عبور جدید'),
                  field(controller: reNewPassword, hint: 'تکرار رمز عبور جدید', textInputAction: TextInputAction.done),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.percentWidth(0.1, min: 24, max: 60), vertical: r.space(20)),
                    child: EasyButton(
                      idleStateWidget: const TextBodyMediumView('ذخیره', color: AppColors.onBrand, fontWeight: FontWeight.bold),
                      loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: AppColors.onBrand)),
                      buttonColor: AppColors.primary,
                      borderRadius: 10,
                      height: r.buttonHeight,
                      onPressed: () async {
                        if (formValidation()) {
                          dynamic jsonUpdatePassword = await httpRequest.updatePassword(
                            context: context,
                            userId: customer.id!,
                            currentPassword: currentPassword.text,
                            newPassword: newPassword.text,
                          );
                          if (jsonUpdatePassword != false) {
                            if (context.mounted) SnackBarView.show(context, 'رمز عبور با موفقیت تغییر یافت');
                            setState((){
                              currentPassword.clear();
                              newPassword.clear();
                              reNewPassword.clear();
                            });
                            profileChanged(true);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field({required TextEditingController controller, required String hint, TextInputAction textInputAction = TextInputAction.next}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        textDirection: TextDirection.ltr,
        obscureText: true,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.appColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          fillColor: context.appColors.surfaceVariant,
          filled: true,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.responsive.radius(10)), borderSide: BorderSide(color: context.appColors.border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.responsive.radius(10)),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  bool formValidation() {
    if (currentPassword.text.isNotEmpty && newPassword.text.isNotEmpty && reNewPassword.text.isNotEmpty) {
      if (newPassword.text == reNewPassword.text) {
        return true;
      } else {
        SnackBarView.show(context, 'رمز عبور جدید با تکرار رمز عبور جدید برابر نیست');
        return false;
      }
    } else {
      SnackBarView.show(context, 'لطفا همه موارد را وارد کنید');
      return false;
    }
  }
}
