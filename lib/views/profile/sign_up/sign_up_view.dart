import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.rePassCtrl,
    required this.obscureText,
    required this.emailErrVis,
    required this.emailErrStr,
    required this.passErrVis,
    required this.passErrStr,
    required this.rePassErrVis,
    required this.rePassErrStr,
    required this.showPass,
    required this.showPassFun,
    required this.signUpFun,
    required this.pageCtrl,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController rePassCtrl;
  final bool emailErrVis;
  final String emailErrStr;
  final bool passErrVis;
  final String passErrStr;
  final bool rePassErrVis;
  final String rePassErrStr;
  final PageController pageCtrl;
  final bool obscureText;
  final bool showPass;
  final void Function(bool?) showPassFun;
  final Future<void> Function() signUpFun;

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
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  errorText: passErrVis ? passErrStr : null,
                ),
                SizedBox(height: r.space(18)),
                AppTextField(
                  controller: rePassCtrl,
                  hint: 'تکرار کلمه عبور',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscureText,
                  keyboardType: TextInputType.visiblePassword,
                  textDirection: TextDirection.ltr,
                  errorText: rePassErrVis ? rePassErrStr : null,
                ),
                SizedBox(height: r.space(12)),
                Align(
                  alignment: Alignment.centerRight,
                  child: CheckboxMenuButton(
                    value: showPass,
                    onChanged: showPassFun,
                    child: const AppText.bodySmall('نمایش کلمه عبور'),
                  ),
                ),
                SizedBox(height: r.space(16)),
                EasyButton(
                  idleStateWidget: const AppText.labelLarge('ثبت‌نام', color: AppColors.onBrand, fontWeight: FontWeight.w700),
                  loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: AppColors.onBrand, size: 24)),
                  buttonColor: AppColors.primary,
                  width: double.infinity,
                  height: r.buttonHeight,
                  borderRadius: r.radius(14),
                  onPressed: signUpFun,
                ),
                SizedBox(height: r.space(18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText.bodyMedium('قبلاً ثبت‌نام کرده‌اید؟'),
                    SizedBox(width: r.space(5)),
                    InkWell(
                      onTap: () => pageCtrl.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                      child: const AppText.bodyMedium('وارد شوید', color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: r.space(18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
