import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/cards/image_card_widget.dart';
import 'package:yad_sys/widgets/home/menu_section.dart';
import 'package:yad_sys/widgets/home/image_slider.dart';
import 'package:yad_sys/widgets/home/section_header.dart';

class ImageSection extends StatefulWidget {
  const ImageSection({super.key, required this.section});

  final SectionModel section;

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.section.images;
    final sectionId = widget.section.id;

    return Column(
      children: [
        SectionHeader(section: widget.section),
        if (sectionId.contains('header_banners'))
          ImageSlider(currentIndex: _currentIndex, items: items)
        else if (sectionId.contains('menu'))
          MenuSection(section: widget.section)
        else
          ImageCardWidget(section: widget.section),
      ],
    );
  }
}
