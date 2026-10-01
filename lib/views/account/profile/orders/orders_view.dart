import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/account/account_empty_state.dart';
import 'package:yad_sys/widgets/net_image.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key, required this.orders});
  final List<CustomerOrderModel> orders;

  @override
  Widget build(BuildContext context) {
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
        body: TabBarView(
          children: [
            _OrderList(orders: _byStatuses(const {'processing'})),
            _OrderList(orders: _reviewOrders()),
            _OrderList(orders: _byStatuses(const {'completed'})),
            _OrderList(orders: _byStatuses(const {'shipped', 'wc-shipped', 'post', 'posted', 'out-for-delivery', 'delivered-to-post'})),
            _OrderList(orders: _byStatuses(const {'cancelled', 'refunded', 'failed'})),
          ],
        ),
      ),
    );
  }

  List<CustomerOrderModel> _byStatuses(Set<String> statuses) {
    return orders.where((order) => statuses.contains(order.status.toLowerCase())).toList(growable: false);
  }

  List<CustomerOrderModel> _reviewOrders() {
    const known = <String>{'processing', 'completed', 'shipped', 'wc-shipped', 'post', 'posted', 'out-for-delivery', 'delivered-to-post', 'cancelled', 'refunded', 'failed'};
    return orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'pending' || status == 'on-hold' || !known.contains(status);
    }).toList(growable: false);
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});
  final List<CustomerOrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const AccountEmptyState(icon: Icons.receipt_long_outlined, title: 'سفارشی وجود ندارد', message: 'سفارشی با این وضعیت پیدا نشد.');
    }
    final r = context.responsive;
    return ListView.separated(
      padding: EdgeInsets.all(r.pageHorizontalPadding),
      itemCount: orders.length,
      separatorBuilder: (_, _) => SizedBox(height: r.space(12)),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final CustomerOrderModel order;

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
                return SizedBox(
                  width: size,
                  child: Column(
                    children: [
                      Expanded(child: NetImage(imageUrl: item.image, width: size, height: size)),
                    ],
                  ),
                );
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
