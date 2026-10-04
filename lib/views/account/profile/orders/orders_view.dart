import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/order/order_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/view_models/account/profile/orders_view_model.dart';
import 'package:yad_sys/widgets/account/account_empty_state.dart';
import 'package:yad_sys/widgets/buttons/app_button.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key, required this.viewModel});

  final OrdersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return Scaffold(backgroundColor: context.appColors.background, body: const Loading());
    }

    if (viewModel.errorMessage.isNotEmpty && viewModel.items.isEmpty) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(centerTitle: true, title: const AppText.titleMedium('سفارشات', fontWeight: FontWeight.w700)),
        body: _error(context),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          centerTitle: true,
          title: const AppText.titleMedium('سفارشات', fontWeight: FontWeight.w700),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'درحال انجام'),
              Tab(text: 'درحال بررسی'),
              Tab(text: 'تکمیل شده'),
              Tab(text: 'تحویل پست'),
              Tab(text: 'لغو شده'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _OrderList(orders: _byStatuses(const {'processing'}), onRefresh: viewModel.refresh),
                _OrderList(orders: _reviewOrders(), onRefresh: viewModel.refresh),
                _OrderList(orders: _byStatuses(const {'completed'}), onRefresh: viewModel.refresh),
                _OrderList(
                  orders: _byStatuses(const {'shipped', 'wc-shipped', 'post', 'posted', 'out-for-delivery', 'delivered-to-post'}),
                  onRefresh: viewModel.refresh,
                ),
                _OrderList(orders: _byStatuses(const {'cancelled', 'refunded', 'failed'}), onRefresh: viewModel.refresh),
              ],
            ),
            if (viewModel.isRefreshing) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
          ],
        ),
      ),
    );
  }

  List<OrderModel> _byStatuses(Set<String> statuses) {
    return viewModel.items.where((order) => statuses.contains(order.status.toLowerCase())).toList(growable: false);
  }

  List<OrderModel> _reviewOrders() {
    const known = <String>{
      'processing',
      'completed',
      'shipped',
      'wc-shipped',
      'post',
      'posted',
      'out-for-delivery',
      'delivered-to-post',
      'cancelled',
      'refunded',
      'failed',
    };

    return viewModel.items.where((order) {
      final status = order.status.toLowerCase();
      return status == 'pending' || status == 'on-hold' || !known.contains(status);
    }).toList(growable: false);
  }

  Widget _error(BuildContext context) {
    final r = context.responsive;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pageHorizontalPadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: context.appColors.textMuted, size: r.icon(62)),
            SizedBox(height: r.space(14)),
            AppText.bodyMedium(viewModel.errorMessage, textAlign: TextAlign.center, color: context.appColors.textSecondary),
            SizedBox(height: r.space(14)),
            AppButton(label: 'تلاش دوباره', expand: false, icon: Icons.refresh_rounded, onPressed: () => viewModel.load(refresh: true)),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.onRefresh});

  final List<OrderModel> orders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AccountEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'سفارشی وجود ندارد',
                message: 'سفارشی با این وضعیت پیدا نشد.',
              ),
            ),
          ],
        ),
      );
    }

    final r = context.responsive;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pageHorizontalPadding),
        itemCount: orders.length,
        separatorBuilder: (_, _) => SizedBox(height: r.space(12)),
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.all(r.space(12)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(14)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: AppText.titleSmall('سفارش #${order.id.toString().toPersianDigit()}', fontWeight: FontWeight.w800)),
              _StatusChip(status: order.status),
            ],
          ),
          SizedBox(height: r.space(8)),
          AppText.bodySmall('تاریخ: ${order.date}', color: colors.textSecondary),
          if (order.paymentMethod.isNotEmpty) ...[
            SizedBox(height: r.space(4)),
            AppText.bodySmall(order.paymentMethod, color: colors.textSecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          SizedBox(height: r.space(12)),
          SizedBox(
            height: r.percentWidth(0.20, min: 72, max: 100),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: order.items.length,
              separatorBuilder: (_, _) => SizedBox(width: r.space(8)),
              itemBuilder: (context, index) {
                final item = order.items[index];
                final size = r.percentWidth(0.20, min: 72, max: 100);
                return SizedBox(width: size, child: NetImage(imageUrl: item.image, width: size, height: size));
              },
            ),
          ),
          SizedBox(height: r.space(12)),
          Row(
            children: [
              AppText.bodySmall('${order.itemCount.toString().toPersianDigit()} کالا', color: colors.textSecondary),
              const Spacer(),
              AppText.bodyMedium('${order.total.toString().seRagham().toPersianDigit()} تومان', fontWeight: FontWeight.w800),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final value = status.toLowerCase();
    final (label, color) = switch (value) {
      'processing' => ('درحال انجام', colors.info),
      'pending' || 'on-hold' => ('درحال بررسی', colors.warning),
      'completed' => ('تکمیل شده', colors.success),
      'shipped' || 'wc-shipped' || 'post' || 'posted' || 'out-for-delivery' || 'delivered-to-post' => ('تحویل پست', AppColors.primary),
      'cancelled' || 'refunded' || 'failed' => ('لغو شده', AppColors.error),
      _ => (status, colors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.responsive.space(8), vertical: context.responsive.space(4)),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(context.responsive.radius(20))),
      child: AppText.labelSmall(label, color: color, fontWeight: FontWeight.w700),
    );
  }
}
