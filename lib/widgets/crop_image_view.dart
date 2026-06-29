import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:yad_sys/themes/color_style.dart';

Future<CroppedFile> cropImageView({required BuildContext context, required String imageFile}) async {
  CroppedFile? file;
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile,
    maxWidth: 512,
    maxHeight: 512,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'عکس خود را برش دهید',
        toolbarColor: ColorStyle.blueFav,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: ColorStyle.blueFav,
        lockAspectRatio: false,
        cropStyle: CropStyle.circle,
      ),
      IOSUiSettings(title: 'عکس خود را برش دهید', cropStyle: CropStyle.circle),
    ],
  );
  if (croppedFile != null) file = croppedFile;
  return file!;
}
