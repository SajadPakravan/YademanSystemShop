import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yad_sys/screens/search/search_screen.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 3),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.black54),
            SizedBox(width: 5),
            TextBodyMediumView("جستجو در "),
            TextBodyLargeView("یادمان سیستم", fontWeight: FontWeight.bold, color: Colors.red),
          ],
        ),
      ),
      onTap: () {
        Get.to(const SearchScreen(), transition: Transition.upToDown, duration: const Duration(milliseconds: 500));
      },
    );
  }
}
