import 'package:flutter/material.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

selectFilter({required BuildContext context, required List<Map<String, dynamic>> filtersLst, required int selected, required Function() onPressed}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.red,
    showDragHandle: true,
    enableDrag: true,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Wrap(
                  children: List.generate(
                    filtersLst.length,
                    (index) {
                      return option(
                        title: filtersLst[index]['name'],
                        selected: selected,
                        value: filtersLst[index]['index'],
                        onChanged: (int? v) {
                          for (var filter in filtersLst) {
                            setState(() => filter['select'] = false);
                          }
                          setState(() {
                            selected = v!;
                            filtersLst[index]['select'] = true;
                          });
                        },
                        onTap: () {
                          for (var filter in filtersLst) {
                            setState(() => filter['select'] = false);
                          }
                          setState(() {
                            selected = index;
                            filtersLst[index]['select'] = true;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            bottomNavigationBar: ElevatedButton(
              onPressed: () {
                onPressed();
                Navigator.pop(context);
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(const RoundedRectangleBorder()),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) return Colors.grey;
                    return ColorStyle.blueFav;
                  },
                ),
              ),
              child: const TextBodyMediumView('انتخاب', color: Colors.white),
            ),
          );
        },
      );
    },
  );
}

option({required String title, required int value, int? selected, required Function(int?) onChanged, required Function() onTap}) {
  return ListTile(
    title: InkWell(onTap: onTap, child: TextBodyMediumView(title)),
    leading: Radio<int>(value: value, groupValue: selected, onChanged: onChanged),
  );
}
