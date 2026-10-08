import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/app_input_formatter.dart';
import 'package:yad_sys/view_models/account/profile/personal_info_view_model.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/bottom_sheet/bottom_sheet_pick_image.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/forms/app_text_field.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class PersonalInfoView extends StatelessWidget {
  const PersonalInfoView({super.key, required this.viewModel});

  final PersonalInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    // تا پیش از اولین GET موفق، فرم ناقص از کش کم‌حجم نمایش داده نمی‌شود.
    if (viewModel.isLoading) return const Scaffold(body: Loading());
    if (viewModel.errorMessage.startsWith('دریافت مشخصات فردی انجام نشد')) {
      return Scaffold(
        appBar: const AppBarView(title: 'مشخصات فردی'),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppText.bodyMedium(viewModel.errorMessage),
          TextButton(onPressed: viewModel.initialize, child: const Text('تلاش مجدد')),
        ])),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: const AppBarView(title: 'مشخصات فردی'),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(28)),
            child: Column(
              spacing: r.space(15),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                avatar(context),
                SizedBox(height: r.space(10)),
                nameFields(context),
                // نام نمایشی از API خوانده می‌شود و دیگر قابل تغییر نیست.
                AppTextField(
                  controller: viewModel.usernameController,
                  title: 'نام کاربری', hint: 'نام کاربری',
                  textDirection: TextDirection.ltr,
                  icon: Icons.alternate_email_rounded,
                  errorText: viewModel.usernameError,
                  textInputAction: TextInputAction.next,
                  inputFormatters: AppInputFormatter.formatters(AppInputType.englishLettersAndNumbers),
                  onChanged: (_) => viewModel.fieldChanged(),
                ),
                AppTextField(
                  controller: viewModel.phoneController,
                  title: 'شماره همراه',
                  hint: 'شماره همراه',
                  textDirection: TextDirection.ltr,
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  errorText: viewModel.phoneError,
                  textInputAction: TextInputAction.next,
                  inputFormatters: AppInputFormatter.formatters(AppInputType.numbers, maxLength: 11),
                  onChanged: (_) => viewModel.fieldChanged(),
                ),
                AppTextField(
                  controller: viewModel.emailController,
                  title: 'ایمیل',
                  hint: 'ایمیل',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  errorText: viewModel.emailError,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => viewModel.fieldChanged(),
                  onSubmitted: (_) => submit(context),
                ),
                if (viewModel.errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(r.space(10)),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(r.radius(10))),
                    child: AppText.bodySmall(viewModel.errorMessage, color: AppColors.error, textAlign: TextAlign.center),
                  ),
                SizedBox(height: r.space(10)),
                AppButton(
                  label: 'ثبت تغییرات',
                  icon: Icons.save_outlined,
                  loading: viewModel.saving,
                  enabled: viewModel.formChanged,
                  onPressed: () => submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget avatar(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final size = r.icon(112, min: 96, max: 132);

    Widget avatar;
    if (viewModel.avatarFilePath != null) {
      avatar = Image.file(File(viewModel.avatarFilePath!), width: size, height: size, fit: BoxFit.cover);
    } else if (viewModel.customer.avatar.isNotEmpty) {
      avatar = NetImage(imageUrl: viewModel.customer.avatar, width: size, height: size);
    } else {
      avatar = Container(
        width: size,
        height: size,
        color: colors.surfaceVariant,
        child: Icon(Icons.person_rounded, size: r.icon(56), color: colors.textMuted),
      );
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: SizedBox(width: size, height: size, child: avatar),
          ),
          Positioned(
            bottom: -2,
            left: -2,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: viewModel.pickingAvatar || viewModel.saving ? null : () => showAvatarSource(context),
                child: Padding(
                  padding: EdgeInsets.all(r.space(9)),
                  child: viewModel.pickingAvatar
                      ? SizedBox(
                          width: r.icon(20),
                          height: r.icon(20),
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.onBrand),
                        )
                      : Icon(Icons.edit, color: AppColors.onBrand, size: r.icon(20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nameFields(BuildContext context) {
    final r = context.responsive;

    return Row(
      spacing: r.space(8),
      children: [
        Expanded(
          child: AppTextField(
            controller: viewModel.firstNameController,
            title: 'نام',
            hint: 'نام',
            icon: Icons.badge_outlined,
            errorText: viewModel.firstNameError,
            textInputAction: TextInputAction.next,
            inputFormatters: AppInputFormatter.formatters(AppInputType.persianLetters),
            onChanged: (_) => viewModel.fieldChanged(),
          ),
        ),
        Expanded(
          child: AppTextField(
            controller: viewModel.lastNameController,
            title: 'نام خانوادگی',
            hint: 'نام خانوادگی',
            icon: Icons.badge_outlined,
            errorText: viewModel.lastNameError,
            textInputAction: TextInputAction.next,
            inputFormatters: AppInputFormatter.formatters(AppInputType.persianLetters),
            onChanged: (_) => viewModel.fieldChanged(),
          ),
        ),
      ],
    );
  }

  void showAvatarSource(BuildContext context) {
    bottomSheetPickImage(
      context: context,
      onTapCamera: () {
        Navigator.of(context).pop();
        viewModel.pickAvatar(context, ImageSource.camera);
      },
      onTapGallery: () {
        Navigator.of(context).pop();
        viewModel.pickAvatar(context, ImageSource.gallery);
      },
    );
  }

  Future<void> submit(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await viewModel.submit();
    if (success && context.mounted && viewModel.updatedCustomer != null) Navigator.pop(context, viewModel.updatedCustomer);
  }
}
