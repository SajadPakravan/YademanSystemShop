import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yad_sys/tools/app_colors.dart';

Future<CroppedFile?> cropImageView({required BuildContext context, required String imageFile}) async {
  return ImageCropper().cropImage(
    sourcePath: imageFile,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 92,
    maxWidth: 1024,
    maxHeight: 1024,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'عکس خود را تنظیم کنید',
        toolbarColor: context.appColors.surface,
        statusBarLight: !context.isDarkMode,
        toolbarWidgetColor: context.appColors.textPrimary,
        navBarLight: !context.isDarkMode,
        activeControlsWidgetColor: AppColors.primary,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        cropStyle: CropStyle.circle,
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: 'عکس خود را تنظیم کنید',
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
        rotateButtonsHidden: false,
      ),
    ],
  );
}
