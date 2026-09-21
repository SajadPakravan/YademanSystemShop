import 'package:flutter/material.dart';
import 'package:yad_sys/models/section_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/tools/section_action_handler.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final title = section.title.trim();
    final subtitle = section.subtitle.trim();
    final hasTitle = title.isNotEmpty;
    final hasSubtitle = subtitle.isNotEmpty;
    final hasViewAll = section.viewAll != null;
    final r = context.responsive;
    final colors = context.appColors;

    if (!hasTitle && !hasViewAll) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasTitle)
            Expanded(
              child: hasSubtitle
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: hasViewAll ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        AppText.titleMedium(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          height: 1.25,
                        ),
                        SizedBox(height: r.space(3)),
                        AppText.bodySmall(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: colors.textSecondary,
                          height: 1.3,
                        ),
                      ],
                    )
                  : Align(
                      alignment: hasViewAll ? AlignmentDirectional.centerStart : Alignment.center,
                      child: AppText.titleMedium(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        height: 1.25,
                      ),
                    ),
            )
          else
            const Spacer(),
          if (hasViewAll)
            _ViewAllButton(
              title: section.viewAll!.title,
              onTap: () {
                if (section.type == 'products') {
                  SectionActionHandler.openProductListInShop(context: context, action: section.viewAll!.action);
                } else {
                  SectionActionHandler.handle(context: context, action: section.viewAll!.action);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(10)),
        child: Padding(
          padding: EdgeInsets.all(r.space(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.labelMedium(title.trim(), color: colors.textSecondary, fontWeight: FontWeight.w600),
              SizedBox(width: r.space(6)),
              Icon(Icons.arrow_forward_ios_rounded, color: colors.textSecondary, size: r.icon(18, min: 16, max: 21)),
            ],
          ),
        ),
      ),
    );
  }
}
