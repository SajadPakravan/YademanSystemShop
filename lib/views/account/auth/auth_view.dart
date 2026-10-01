import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/account_view_model.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final PageController _pageController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerIdentifierController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();
  final _loginIdentifierFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _registerIdentifierFocus = FocusNode();
  final _registerPasswordFocus = FocusNode();
  final _registerConfirmFocus = FocusNode();
  bool _hideLoginPassword = true;
  bool _hideRegisterPassword = true;
  bool _hideRegisterConfirm = true;

  AccountViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _registerIdentifierController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    _loginIdentifierFocus.dispose();
    _loginPasswordFocus.dispose();
    _registerIdentifierFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmFocus.dispose();
    super.dispose();
  }

  Future<void> _switchPage(int page) async {
    FocusManager.instance.primaryFocus?.unfocus();
    viewModel.clearError();
    await _pageController.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic);
  }

  Future<void> _submitLogin() async {
    if (viewModel.loading) return;
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await viewModel.login(identifier: _loginIdentifierController.text.trim(), password: _loginPasswordController.text);
  }

  Future<void> _submitRegister() async {
    if (viewModel.loading) return;
    if (!(_registerFormKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await viewModel.register(identifier: _registerIdentifierController.text.trim(), password: _registerPasswordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: _AuthPage(
                  title: 'ورود به حساب کاربری',
                  subtitle: 'برای دسترسی به حساب خود، شناسه کاربری و کلمه عبور را وارد کنید.',
                  icon: Icons.person_outline_rounded,
                  formKey: _loginFormKey,
                  apiError: viewModel.errorMessage,
                  children: [
                    _AuthTextField(
                      controller: _loginIdentifierController,
                      focusNode: _loginIdentifierFocus,
                      label: 'نام کاربری، شماره همراه یا ایمیل',
                      hint: 'شناسه کاربری خود را وارد کنید',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _requiredIdentifierValidator,
                      onSubmitted: (_) => _loginPasswordFocus.requestFocus(),
                    ),
                    _AuthTextField(
                      controller: _loginPasswordController,
                      focusNode: _loginPasswordFocus,
                      label: 'کلمه عبور',
                      hint: 'کلمه عبور خود را وارد کنید',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _hideLoginPassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: _requiredPasswordValidator,
                      onSubmitted: (_) => _submitLogin(),
                      suffixIcon: IconButton(
                        tooltip: _hideLoginPassword ? 'نمایش کلمه عبور' : 'مخفی کردن کلمه عبور',
                        onPressed: () => setState(() => _hideLoginPassword = !_hideLoginPassword),
                        icon: Icon(_hideLoginPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => SnackBarView.show(context, 'بازیابی کلمه عبور در نسخه بعدی فعال می‌شود.'),
                        child: const AppText.bodySmall('فراموشی کلمه عبور', color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    AppButton(label: 'ورود به حساب', icon: Icons.login_rounded, loading: viewModel.loading, onPressed: _submitLogin),
                    _SwitchAuthPage(question: 'هنوز حساب ایجاد نکرده‌اید؟', action: 'یک حساب بسازید', onTap: () => _switchPage(1)),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: _AuthPage(
                  title: 'ایجاد حساب کاربری',
                  subtitle: 'با ایمیل، شماره همراه یا نام کاربری یک حساب جدید ایجاد کنید.',
                  icon: Icons.person_add_alt_1_rounded,
                  formKey: _registerFormKey,
                  apiError: viewModel.errorMessage,
                  children: <Widget>[
                    _AuthTextField(
                      controller: _registerIdentifierController,
                      focusNode: _registerIdentifierFocus,
                      label: 'نام کاربری، شماره همراه یا ایمیل',
                      hint: 'شناسه مورد نظر را وارد کنید',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _registerIdentifierValidator,
                      onSubmitted: (_) => _registerPasswordFocus.requestFocus(),
                    ),
                    _AuthTextField(
                      controller: _registerPasswordController,
                      focusNode: _registerPasswordFocus,
                      label: 'کلمه عبور',
                      hint: 'کلمه عبور را وارد کنید',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _hideRegisterPassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      validator: _requiredPasswordValidator,
                      onSubmitted: (_) => _registerConfirmFocus.requestFocus(),
                      suffixIcon: IconButton(
                        tooltip: _hideRegisterPassword ? 'نمایش کلمه عبور' : 'مخفی کردن کلمه عبور',
                        onPressed: () => setState(() => _hideRegisterPassword = !_hideRegisterPassword),
                        icon: Icon(_hideRegisterPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                    _AuthTextField(
                      controller: _registerConfirmController,
                      focusNode: _registerConfirmFocus,
                      label: 'تکرار کلمه عبور',
                      hint: 'کلمه عبور را دوباره وارد کنید',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _hideRegisterConfirm,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: _confirmPasswordValidator,
                      onSubmitted: (_) => _submitRegister(),
                      suffixIcon: IconButton(
                        tooltip: _hideRegisterConfirm ? 'نمایش کلمه عبور' : 'مخفی کردن کلمه عبور',
                        onPressed: () => setState(() => _hideRegisterConfirm = !_hideRegisterConfirm),
                        icon: Icon(_hideRegisterConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => SnackBarView.show(context, 'بازیابی نام کاربری در نسخه بعدی فعال می‌شود.'),
                        child: const AppText.bodySmall('فراموشی نام کاربری', color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    AppButton(label: 'ایجاد حساب', icon: Icons.person_add_alt_rounded, loading: viewModel.loading, onPressed: _submitRegister),
                    _SwitchAuthPage(question: 'قبلاً حساب ساخته‌اید؟', action: 'وارد حساب شوید', onTap: () => _switchPage(0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredIdentifierValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'شناسه کاربری را وارد کنید.';
    return null;
  }

  String? _requiredPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'کلمه عبور را وارد کنید.';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'تکرار کلمه عبور را وارد کنید.';
    if (value != _registerPasswordController.text) return 'تکرار کلمه عبور با کلمه عبور یکسان نیست.';
    return null;
  }

  String? _registerIdentifierValidator(String? value) {
    final identifier = value?.trim() ?? '';
    if (identifier.isEmpty) return 'شناسه کاربری را وارد کنید.';

    if (identifier.contains('@')) {
      final emailRegex = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$");
      if (!emailRegex.hasMatch(identifier)) return 'ایمیل وارد شده معتبر نیست.';
      return null;
    }

    final normalizedMobile = identifier.replaceAll(RegExp(r'[\s-]'), '');
    final looksLikeIranMobile = normalizedMobile.startsWith('09') || normalizedMobile.startsWith('+989') || normalizedMobile.startsWith('989');
    if (looksLikeIranMobile) {
      final mobileRegex = RegExp(r'^(?:09\d{9}|\+989\d{9}|989\d{9})$');
      if (!mobileRegex.hasMatch(normalizedMobile)) return 'شماره همراه وارد شده معتبر نیست.';
      return null;
    }

    if (identifier.length < 4) return 'نام کاربری باید حداقل ۴ کاراکتر باشد.';
    return null;
  }
}

class _AuthPage extends StatelessWidget {
  const _AuthPage({required this.title, required this.subtitle, required this.icon, required this.formKey, required this.children, required this.apiError});

  final String title;
  final String subtitle;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String apiError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsetsDirectional.fromSTEB(r.pageHorizontalPadding, r.space(22), r.pageHorizontalPadding, r.space(24) + keyboard),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.isTablet ? 540 : 500, minHeight: mathMax(0, constraints.maxHeight - r.space(46))),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: r.icon(94, min: 82, max: 116),
                        height: r.icon(94, min: 82, max: 116),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceVariant,
                          border: Border.all(color: colors.border),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.10), blurRadius: r.space(22), spreadRadius: r.space(2)),
                          ],
                        ),
                        child: Icon(icon, color: AppColors.primary, size: r.icon(48, min: 42, max: 60)),
                      ),
                    ),
                    SizedBox(height: r.space(18)),
                    AppText.titleLarge(title, textAlign: TextAlign.center, fontWeight: FontWeight.w800, color: colors.textPrimary),
                    SizedBox(height: r.space(8)),
                    AppText.bodySmall(subtitle, textAlign: TextAlign.center, color: colors.textSecondary, height: 1.8),
                    SizedBox(height: r.space(24)),
                    if (apiError.isNotEmpty) ...<Widget>[
                      Container(
                        padding: EdgeInsets.all(r.space(12)),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: context.isDarkMode ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(r.radius(12)),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline_rounded, color: AppColors.error, size: r.icon(21)),
                            SizedBox(width: r.space(8)),
                            Expanded(child: AppText.bodySmall(apiError, color: colors.textPrimary, height: 1.7)),
                          ],
                        ),
                      ),
                      SizedBox(height: r.space(14)),
                    ],
                    ..._spaced(children, r.space(14)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _spaced(List<Widget> children, double spacing) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) result.add(SizedBox(height: spacing));
      result.add(children[i]);
    }
    return result;
  }

  static double mathMax(double a, double b) => a > b ? a : b;
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      autofillHints: obscureText ? const <String>[AutofillHints.password] : null,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}

class _SwitchAuthPage extends StatelessWidget {
  const _SwitchAuthPage({required this.question, required this.action, required this.onTap});

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: r.space(4),
      children: [
        AppText.bodyMedium(question, color: colors.textSecondary),
        TextButton(
          onPressed: onTap,
          child: AppText.bodyMedium(action, color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
