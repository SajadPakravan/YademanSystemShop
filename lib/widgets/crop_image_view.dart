import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yad_sys/tools/app_colors.dart';

Future<CroppedFile> cropImageView({required BuildContext context, required String imageFile}) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile,
    maxWidth: 512,
    maxHeight: 512,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'عکس خود را برش دهید',
        toolbarColor: AppColors.primary,
        toolbarWidgetColor: AppColors.onBrand,
        activeControlsWidgetColor: AppColors.primary,
        lockAspectRatio: false,
        cropStyle: CropStyle.circle,
      ),
      IOSUiSettings(title: 'عکس خود را برش دهید', cropStyle: CropStyle.circle),
    ],
  );
  if (croppedFile == null) throw StateError('Image crop was cancelled');
  return croppedFile;
}
