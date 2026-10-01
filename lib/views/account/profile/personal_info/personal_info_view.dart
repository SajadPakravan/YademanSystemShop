import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class PersonalInfoView extends StatefulWidget {
  const PersonalInfoView({super.key, required this.customer});

  final CustomerModel customer;

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  late final TextEditingController _username;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  String? _usernameError;
  String? _phoneError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.customer.username);
    _firstName = TextEditingController(text: widget.customer.firstName);
    _lastName = TextEditingController(text: widget.customer.lastName);
    _phone = TextEditingController(text: widget.customer.phone);
    _email = TextEditingController(text: widget.customer.email);
  }

  @override
  void dispose() {
    _username.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _username.text.trim() != widget.customer.username ||
      _firstName.text.trim() != widget.customer.firstName ||
      _lastName.text.trim() != widget.customer.lastName ||
      _phone.text.trim() != widget.customer.phone ||
      _email.text.trim() != widget.customer.email;

  bool _validate() {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();

    setState(() {
      _usernameError = username.length < 4 ? 'نام کاربری باید حداقل ۴ کاراکتر باشد.' : null;
      _phoneError = phone.isNotEmpty && !RegExp(r'^(?:\+98|0098|98|0)?9\d{9}$').hasMatch(phone) ? 'شماره همراه معتبر نیست.' : null;
      _emailError = email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ? 'ایمیل معتبر نیست.' : null;
    });

    return _usernameError == null && _phoneError == null && _emailError == null;
  }

  void _submit() {
    if (!_dirty) return;
    if (!_validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API ویرایش مشخصات فردی هنوز فعال نشده است. فرم برای اتصال به API آماده است.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppBarView(title: 'مشخصات فردی'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: widget.customer.avatar.isNotEmpty
                          ? NetImage(imageUrl: widget.customer.avatar, width: r.icon(104), height: r.icon(104))
                          : Container(
                              width: r.icon(104),
                              height: r.icon(104),
                              color: colors.surfaceVariant,
                              child: Icon(Icons.person_rounded, size: r.icon(54), color: colors.textMuted),
                            ),
                    ),
                    Positioned(
                      bottom: -2,
                      left: -2,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('آپلود آواتار بعد از آماده‌شدن API ویرایش فعال می‌شود.')),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(r.space(9)),
                            child: Icon(Icons.camera_alt_rounded, color: AppColors.onBrand, size: r.icon(20)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.space(22)),
              const AppText.titleSmall('اطلاعات حساب', fontWeight: FontWeight.w800),
              SizedBox(height: r.space(14)),
              _fieldLabel(context, 'نام کاربری'),
              AppTextField(controller: _username, hint: 'نام کاربری', icon: Icons.alternate_email_rounded, errorText: _usernameError, onChanged: (_) => setState(() {})),
              SizedBox(height: r.space(12)),
              _fieldLabel(context, 'نام'),
              AppTextField(controller: _firstName, hint: 'نام', icon: Icons.badge_outlined, onChanged: (_) => setState(() {})),
              SizedBox(height: r.space(12)),
              _fieldLabel(context, 'نام خانوادگی'),
              AppTextField(controller: _lastName, hint: 'نام خانوادگی', icon: Icons.badge_outlined, onChanged: (_) => setState(() {})),
              SizedBox(height: r.space(12)),
              _fieldLabel(context, 'شماره همراه'),
              AppTextField(
                controller: _phone,
                hint: 'شماره همراه',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: r.space(12)),
              _fieldLabel(context, 'ایمیل'),
              AppTextField(
                controller: _email,
                hint: 'ایمیل',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                errorText: _emailError,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: r.space(22)),
              AppButton(label: 'ثبت تغییرات', enabled: _dirty, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.responsive.space(6)),
      child: AppText.labelMedium(text, color: context.appColors.textSecondary, fontWeight: FontWeight.w700),
    );
  }
}
