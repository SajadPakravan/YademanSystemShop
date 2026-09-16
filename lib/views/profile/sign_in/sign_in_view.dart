import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/screens/profile/forget_password/forget_password_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SignInView extends StatelessWidget {
  const SignInView({
    super.key,
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

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscureText;
  final bool showPass;
  final void Function(bool?) showPassFun;
  final Future<void> Function() signInFun;
  final bool emailErrVis;
  final String emailErrStr;
  final bool passErrVis;
  final String passErrStr;
  final PageController pageCtrl;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.isTablet ? 520 : double.infinity),
            child: Column(
              children: [
                AppTextField(
                  controller: emailCtrl,
                  hint: 'ایمیل',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  errorText: emailErrVis ? emailErrStr : null,
                ),
                SizedBox(height: r.space(18)),
                AppTextField(
                  controller: passCtrl,
                  hint: 'کلمه عبور',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  textDirection: TextDirection.ltr,
                  errorText: passErrVis ? passErrStr : null,
                ),
                SizedBox(height: r.space(14)),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxMenuButton(
                        value: showPass,
                        onChanged: showPassFun,
                        child: const AppText.bodySmall('نمایش کلمه عبور'),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(r.cardRadius),
                      onTap: () => zoomToPage(const ForgetPassword()),
                      child: Padding(
                        padding: EdgeInsets.all(r.space(8)),
                        child: const AppText.bodySmall('فراموشی کلمه عبور', color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.space(16)),
                EasyButton(
                  idleStateWidget: const AppText.labelLarge('ورود', color: AppColors.onBrand, fontWeight: FontWeight.w700),
                  loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: AppColors.onBrand, size: 24)),
                  buttonColor: AppColors.primary,
                  width: double.infinity,
                  height: r.buttonHeight,
                  borderRadius: r.radius(14),
                  onPressed: signInFun,
                ),
                SizedBox(height: r.space(18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText.bodyMedium('کاربر جدید هستید؟'),
                    SizedBox(width: r.space(5)),
                    InkWell(
                      onTap: () => pageCtrl.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                      child: const AppText.bodyMedium('ثبت‌نام کنید', color: AppColors.primary, fontWeight: FontWeight.w700),
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
}
