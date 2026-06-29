import 'dart:async';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  HttpRequest httpRequest = HttpRequest();
  bool recoveryPassStatus = false;
  TextEditingController email = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'فراموشی رمز عبور'),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  field(controller: email, label: 'ایمیل', readOnly: recoveryPassStatus),
                  field(controller: code, label: 'کد تایید', visible: recoveryPassStatus),
                  field(controller: password, label: 'رمز عبور', visible: recoveryPassStatus, obscureText: true),
                  field(
                    controller: rePassword,
                    label: 'تکرار رمز عبور',
                    visible: recoveryPassStatus,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 20),
                    child: EasyButton(
                      idleStateWidget: TextBodyMediumView(
                        recoveryPassStatus ? 'تغییر رمز' : 'ارسال کد تایید',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: Colors.white)),
                      buttonColor: ColorStyle.blueFav,
                      borderRadius: 10,
                      height: width * 0.13,
                      onPressed: () async {
                        if (recoveryPassStatus) {
                          if (formValidation()) {
                            dynamic jsonPasswordRecovery = await httpRequest.passwordRecovery(
                              context: context,
                              email: email.text,
                              code: code.text,
                              password: int.parse(password.text),
                            );
                            if (jsonPasswordRecovery != false) {
                              if (context.mounted) SnackBarView.show(context, 'رمز عبور شما با موفقیت تغییر یافت\nمی‌توانید با رمزعبور جدید وارد شوید');
                              Future.delayed(const Duration(seconds: 2));
                              Get.back(result: true);
                            }
                          }
                        } else {
                          if (email.text.isEmpty) {
                            SnackBarView.show(context, 'لطفا ایمیل خود را وارد کنید');
                          } else {
                            dynamic jsonVerifyCode = await httpRequest.sendVerifyCode(context: context, email: email.text);
                            if (jsonVerifyCode != false) {
                              if (context.mounted) SnackBarView.show(context, 'کد ارسال شده به ایمیل خود را وارد کنید');
                              setState(() => recoveryPassStatus = true);
                            }
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

  field({
    bool visible = true,
    required TextEditingController controller,
    bool readOnly = false,
    required String label,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.ltr,
          obscureText: obscureText,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context).textTheme.bodyMedium,
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
      ),
    );
  }

  formValidation() {
    if (code.text.isNotEmpty && password.text.isNotEmpty && rePassword.text.isNotEmpty) {
      if (password.text == rePassword.text) {
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
