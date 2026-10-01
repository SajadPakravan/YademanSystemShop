import 'package:flutter/material.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final current = TextEditingController();
  final next = TextEditingController();
  final repeat = TextEditingController();
  bool showCurrent = false;
  bool showNext = false;
  bool showRepeat = false;
  String? error;

  @override
  void dispose() {
    current.dispose(); next.dispose(); repeat.dispose(); super.dispose();
  }

  void submit() {
    setState(() {
      if (current.text.isEmpty || next.text.isEmpty || repeat.text.isEmpty) {
        error = 'همه فیلدها را کامل کنید.';
      } else if (next.text.length < 8) {
        error = 'کلمه عبور جدید باید حداقل ۸ کاراکتر باشد.';
      } else if (next.text != repeat.text) {
        error = 'تکرار کلمه عبور با کلمه عبور جدید یکسان نیست.';
      } else {
        error = null;
      }
    });
    if (error != null) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API تغییر گذرواژه هنوز فعال نشده است.')));
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: const AppBarView(title: 'تغییر گذرواژه'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(22), r.pageHorizontalPadding, r.space(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_reset_rounded, size: r.icon(66), color: AppColors.primary),
              SizedBox(height: r.space(12)),
              const AppText.titleMedium('تغییر کلمه عبور', textAlign: TextAlign.center, fontWeight: FontWeight.w800),
              SizedBox(height: r.space(22)),
              _passwordField(context, controller: current, hint: 'کلمه عبور فعلی', visible: showCurrent, onToggle: () => setState(() => showCurrent = !showCurrent), action: TextInputAction.next),
              SizedBox(height: r.space(12)),
              _passwordField(context, controller: next, hint: 'کلمه عبور جدید', visible: showNext, onToggle: () => setState(() => showNext = !showNext), action: TextInputAction.next),
              SizedBox(height: r.space(12)),
              _passwordField(context, controller: repeat, hint: 'تکرار کلمه عبور جدید', visible: showRepeat, onToggle: () => setState(() => showRepeat = !showRepeat), action: TextInputAction.done, onSubmitted: (_) => submit()),
              if (error != null) ...[
                SizedBox(height: r.space(10)),
                AppText.bodySmall(error!, color: AppColors.error),
              ],
              SizedBox(height: r.space(22)),
              AppButton(label: 'ثبت کلمه عبور جدید', onPressed: submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    required TextInputAction action,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(onPressed: onToggle, icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
      ),
    );
  }
}
