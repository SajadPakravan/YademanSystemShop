import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/screens/profile/forget_password/forget_password_screen.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/app_texts.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class SignInView extends StatelessWidget {
  SignInView({
    super.key,
    required this.context,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscureText,
    required this.showPass,
    required this.showPassFun,
    required this.signInFun,
    required this.emailErrVis,
    required this.emailErrStr,
    required this.passErrVis,
    required this.passErrStr,
    required this.pageCtrl,
  });

  final BuildContext context;
  final AppTexts appTexts = AppTexts();
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscureText;
  final bool showPass;
  final TextInputType keyboardType = TextInputType.emailAddress;
  final IconData icon = Icons.email_rounded;
  final Function showPassFun;
  final Function signInFun;
  final bool emailErrVis;
  final String emailErrStr;
  final bool passErrVis;
  final String passErrStr;
  final PageController pageCtrl;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                textFormField(
                  controller: emailCtrl,
                  hint: 'ایمیل',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorVis: emailErrVis,
                  errorStr: emailErrStr,
                ),
                const SizedBox(height: 20),
                textFormField(
                  controller: passCtrl,
                  hint: 'کلمه عبور',
                  icon: Icons.lock,
                  obscureText: obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  errorVis: passErrVis,
                  errorStr: passErrStr,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckboxMenuButton(
                      value: showPass,
                      onChanged: (v) => showPassFun(v),
                      child: const TextBodyMediumView('نمایش کلمه عبور'),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      child: const TextBodyMediumView('فراموشی کلمه عبور', color: ColorStyle.blueFav),
                      onTap: () => zoomToPage(const ForgetPassword()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                EasyButton(
                  idleStateWidget: const TextBodyMediumView('ورود', color: Colors.white),
                  loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: Colors.white)),
                  buttonColor: ColorStyle.blueFav,
                  width: width,
                  height: 50,
                  borderRadius: width,
                  onPressed: signInFun,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextBodyMediumView('کاربر جدید هستید؟'),
                    const SizedBox(width: 5),
                    InkWell(
                      child: const TextBodyMediumView('ثبت‌نام کنید', color: ColorStyle.blueFav),
                      onTap: () => pageCtrl.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.linear),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  textFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    required TextInputType keyboardType,
    TextInputAction textInputAction = TextInputAction.done,
    required bool errorVis,
    required String errorStr,
  }) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          textInputAction: textInputAction,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(icon),
            fillColor: const Color.fromRGBO(223, 228, 234, 1.0),
            filled: true,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(width)), borderSide: const BorderSide()),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(width)),
              borderSide: const BorderSide(color: ColorStyle.blueFav, width: 2),
            ),
          ),
        ),
        Visibility(
          visible: errorVis,
          child: Padding(padding: const EdgeInsets.only(top: 10), child: TextBodyMediumView(errorStr, color: Colors.red)),
        ),
      ],
    );
  }
}
