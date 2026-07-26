import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/widgets/home/home_section_renderer.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/search.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => const [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              titleSpacing: 10,
              title: Search(),
            ),
          ],
          body: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (isLoading && sections.isEmpty) return const Loading();

    if (errorMessage.isNotEmpty && sections.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
            const Icon(Icons.cloud_off_outlined, color: Colors.black38, size: 72),
            const SizedBox(height: 18),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.8),
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش دوباره'),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: sections.length,
            itemBuilder: (context, index) => HomeSectionRenderer(
              key: ValueKey(sections[index].id),
              section: sections[index],
            ),
          ),
        ),
        if (isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
