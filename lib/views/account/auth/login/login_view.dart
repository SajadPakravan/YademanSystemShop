import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/views/account/auth/auth_field.dart';
import 'package:yad_sys/views/account/auth/auth_page_view.dart';
import 'package:yad_sys/views/account/auth/auth_switch.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthPage(
        title: 'ورود به حساب کاربری',
        subtitle: 'برای دسترسی به حساب خود، شناسه کاربری و کلمه عبور را وارد کنید.',
        icon: Icons.person_outline_rounded,
        formKey: viewModel.loginFormKey,
        apiError: viewModel.errorMessage,
        children: [
          AuthField(
            controller: viewModel.loginIdentifierController,
            focusNode: viewModel.loginIdentifierFocus,
            label: 'نام کاربری، شماره همراه یا ایمیل',
            hint: 'شناسه کاربری خود را وارد کنید',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: viewModel.loginIdentifierValidator,
            onSubmitted: (_) => viewModel.loginPasswordFocus.requestFocus(),
          ),
          AuthField(
            controller: viewModel.loginPasswordController,
            focusNode: viewModel.loginPasswordFocus,
            label: 'کلمه عبور',
            hint: 'کلمه عبور خود را وارد کنید',
            icon: Icons.lock_outline_rounded,
            obscureText: viewModel.hideLoginPassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            validator: viewModel.loginPasswordValidator,
            onSubmitted: (_) => viewModel.submitLogin(),
            suffixIcon: IconButton(
              tooltip: viewModel.hideLoginPassword ? 'نمایش کلمه عبور' : 'مخفی کردن کلمه عبور',
              onPressed: () => viewModel.toggleLoginPassword(),
              icon: Icon(viewModel.hideLoginPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => SnackBarView.show(context, 'بازیابی کلمه عبور در نسخه بعدی فعال می‌شود.'),
              child: AppText.bodySmall('فراموشی کلمه عبور', color: context.appColors.inquiryForeground, fontWeight: FontWeight.w700),
            ),
          ),
          AppButton(label: 'ورود به حساب', icon: Icons.login_rounded, loading: viewModel.loading, onPressed: viewModel.submitLogin),
          AuthSwitch(question: 'هنوز حساب ایجاد نکرده‌اید؟', action: 'یک حساب بسازید', onTap: () => viewModel.switchPage(1)),
        ],
      ),
    );
  }
}
