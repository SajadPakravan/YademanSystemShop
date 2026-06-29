import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/themes/color_style.dart';
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

  profileChanged(bool value) async => await cache.setBool('profileChanged', value);

  @override
  void initState() {
    super.initState();
    profileChanged(false);
    setState(() => customer = Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                    padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 20),
                    child: EasyButton(
                      idleStateWidget: const TextBodyMediumView('ذخیره', color: Colors.white, fontWeight: FontWeight.bold),
                      loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: Colors.white)),
                      buttonColor: ColorStyle.blueFav,
                      borderRadius: 10,
                      height: width * 0.13,
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

  field({required TextEditingController controller, required String hint, TextInputAction textInputAction = TextInputAction.next}) {
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
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          fillColor: const Color.fromRGBO(223, 228, 234, 1.0),
          filled: true,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide()),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorStyle.blueFav),
          ),
        ),
      ),
    );
  }

  formValidation() {
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
