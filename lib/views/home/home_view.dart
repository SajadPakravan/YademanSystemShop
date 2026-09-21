import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/home/home_section_renderer.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/search.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.sections,
    required this.isLoading,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRefresh,
    required this.onRetry,
  });

  final List<SectionModel> sections;
  final bool isLoading;
  final bool isRefreshing;
  final String errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: colors.surface,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: r.space(10),
              title: const Search(),
            ),
          ],
          body: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    if (isLoading && sections.isEmpty) return const Loading();

    if (errorMessage.isNotEmpty && sections.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
          children: [
            SizedBox(height: r.percentHeight(0.16, min: 80, max: 160)),
            Icon(Icons.cloud_off_outlined, color: colors.textMuted, size: r.icon(72, min: 56, max: 82)),
            SizedBox(height: r.space(18)),
            AppText.bodyMedium(errorMessage, textAlign: TextAlign.center, height: 1.8, color: colors.textSecondary),
            SizedBox(height: r.space(18)),
            Center(
              child: SizedBox(
                width: r.percentWidth(0.46, min: 150, max: 220),
                child: AppButton(label: 'تلاش دوباره', icon: Icons.refresh, onPressed: onRetry),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: r.space(20), top: r.space(10)),
      itemCount: sections.length,
      itemBuilder: (context, index) => HomeSectionRenderer(section: sections[index]),
    );
  }
}
