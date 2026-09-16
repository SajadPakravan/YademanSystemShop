import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/order_model.dart';
import 'package:yad_sys/screens/profile/orders/order_tab_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';
import 'package:yad_sys/widgets/text_views/text_title_medium_view.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final HttpRequest httpRequest = HttpRequest();
  final List<OrderModel> ordersLst = [];
  final List<OrderModel> unpaidLst = [];
  final List<OrderModel> processingLst = [];
  final List<OrderModel> completedLst = [];
  final List<OrderModel> canceledLst = [];
  final List<OrderModel> pendingLst = [];
  bool loading = false;

  Future<void> getOrders() async {
    setState(() => loading = true);
    final dynamic jsonOrders = await httpRequest.getOrders();
    for (final o in jsonOrders) {
      final order = OrderModel.fromJson(o);
      ordersLst.add(order);
      if ((order.datePaid ?? '').isEmpty) unpaidLst.add(order);
      if (order.status == 'processing') processingLst.add(order);
      if (order.status == 'cancelled') canceledLst.add(order);
      if (order.status == 'completed') completedLst.add(order);
      if (order.status == 'pending') pendingLst.add(order);
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const TextTitleMediumView('سفارشات'),
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: EdgeInsets.all(r.space(5)),
              tabAlignment: TabAlignment.center,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(r.radius(10)),
                color: AppColors.primary,
              ),
              labelColor: AppColors.onBrand,
              unselectedLabelColor: colors.textSecondary,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              tabs: const [
                Tab(text: 'درحال بررسی'),
                Tab(text: 'در انتظار پرداخت'),
                Tab(text: 'درحال پردازش'),
                Tab(text: 'تکمیل شده'),
                Tab(text: 'لغو شده'),
              ],
            ),
          ),
          body: loading
              ? const Loading()
              : ordersLst.isEmpty
                  ? const Center(child: TextBodyMediumView('شما هنوز سفارشی ثبت نکردید'))
                  : TabBarView(
                      children: [
                        OrderTabScreen(list: pendingLst),
                        OrderTabScreen(list: unpaidLst),
                        OrderTabScreen(list: processingLst),
                        OrderTabScreen(list: completedLst),
                        OrderTabScreen(list: canceledLst),
                      ],
                    ),
        ),
      ),
    );
  }
}
