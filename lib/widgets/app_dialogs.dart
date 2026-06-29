import 'package:flutter/material.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class AppDialogs {
  editeValue({
    required BuildContext context,
    required String value,
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType textInputType = TextInputType.name,
    TextDirection textDirection = TextDirection.rtl,
    required Function() onPressed,
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => throw UnimplementedError(),
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.linear.transform(a1.value);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Transform.scale(
            scale: curve,
            child: Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: ListTile(
                title: Container(
                  width: width,
                  height: height * 0.08,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: ColorStyle.blueFav,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  child: TextBodyLargeView(title, color: Colors.white),
                ),
                subtitle: Container(
                  width: width,
                  height: height * 0.3,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: controller,
                        keyboardType: textInputType,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textDirection: textDirection,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade600),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          fillColor: const Color.fromRGBO(223, 228, 234, 1.0),
                          filled: true,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide()),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorStyle.blueFav),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            child: const TextBodyMediumView('ثبت', color: Colors.white),
                            onPressed: () {
                              controller.text.trim();
                              onPressed();
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: const TextBodyMediumView('بستن', color: Colors.white),
                            onPressed: () {
                              controller.text = value;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
