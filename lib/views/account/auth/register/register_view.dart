import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/views/account/auth/auth_field.dart';
import 'package:yad_sys/views/account/auth/auth_page_view.dart';
import 'package:yad_sys/views/account/auth/auth_switch.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthPage(
        title: 'ایجاد حساب کاربری',
        subtitle: 'با ایمیل، شماره همراه یا نام کاربری یک حساب جدید ایجاد کنید.',
        icon: Icons.person_add_alt_1_rounded,
        formKey: viewModel.registerFormKey,
        apiError: viewModel.errorMessage,
        children: [
          AuthField(
            controller: viewModel.registerIdentifierController,
            focusNode: viewModel.registerIdentifierFocus,
            label: 'نام کاربری، شماره همراه یا ایمیل',
            hint: 'شناسه مورد نظر را وارد کنید',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: viewModel.registerIdentifierValidator,
            onSubmitted: (_) => viewModel.registerPasswordFocus.requestFocus(),
          ),
          AuthField(
            controller: viewModel.registerPasswordController,
            focusNode: viewModel.registerPasswordFocus,
            label: 'کلمه عبور',
            hint: 'کلمه عبور را وارد کنید',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            validator: viewModel.registerPasswordValidator,
            onSubmitted: (_) => viewModel.confirmPasswordFocus.requestFocus(),
          ),
          AuthField(
            controller: viewModel.confirmPasswordController,
            focusNode: viewModel.confirmPasswordFocus,
            label: 'تکرار کلمه عبور',
            hint: 'کلمه عبور را دوباره وارد کنید',
            icon: Icons.lock_reset_rounded,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            validator: viewModel.confirmPasswordValidator,
            onSubmitted: (_) => viewModel.submitRegister(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => SnackBarView.show(context, 'بازیابی نام کاربری در نسخه بعدی فعال می‌شود.'),
              child: AppText.bodySmall('فراموشی نام کاربری', color: context.appColors.inquiryForeground, fontWeight: FontWeight.w700),
            ),
          ),
          AppButton(label: 'ایجاد حساب', icon: Icons.person_add_alt_rounded, loading: viewModel.loading, onPressed: viewModel.submitRegister),
          AuthSwitch(question: 'قبلاً حساب ساخته‌اید؟', action: 'وارد حساب شوید', onTap: () => viewModel.switchPage(0)),
        ],
      ),
    );
  }
}
