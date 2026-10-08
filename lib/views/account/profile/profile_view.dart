import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile_view_model.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/profile/profile_menu_grid.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.viewModel, required this.logout});

  final ProfileViewModel viewModel;
  final Future<void> Function() logout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;
    final customer = viewModel.customer;

    if(customer == null) return Loading();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refreshCustomer,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(18), r.pageHorizontalPadding, r.space(28)),
            children: [
              header(context, customer),
              SizedBox(height: r.space(20)),
              if (viewModel.isRefreshing) ...[const LinearProgressIndicator(minHeight: 2), SizedBox(height: r.space(20))],
              ProfileMenuGrid(customer: customer, viewModel: viewModel, logout: logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context, CustomerModel customer) {
    final colors = context.appColors;
    final r = context.responsive;
    final avatarSize = r.icon(94, min: 82, max: 116);

    return Container(
      padding: EdgeInsets.all(r.space(16)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        spacing: r.space(10),
        children: [
          ClipOval(
            child: NetImage(imageUrl: customer.avatar, width: avatarSize, height: avatarSize),
          ),
          Expanded(
            child: Column(
              spacing: r.space(5),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleMedium(customer.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w800),
                AppText.bodyMedium(
                  '@${customer.username}',
                  color: colors.textSecondary,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
