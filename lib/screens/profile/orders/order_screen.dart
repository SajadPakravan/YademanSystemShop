import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/models/order_model.dart';
import 'package:yad_sys/screens/profile/orders/order_tab_screen.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';
import 'package:yad_sys/widgets/text_views/text_title_medium_view.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  HttpRequest httpRequest = HttpRequest();
  List<OrderModel> ordersLst = [];
  List<OrderModel> unpaidLst = [];
  List<OrderModel> processingLst = [];
  List<OrderModel> completedLst = [];
  List<OrderModel> canceledLst = [];
  List<OrderModel> pendingLst = [];
  bool loading = false;

  getOrders() async {
    setState(() => loading = true);
    dynamic jsonOrders = await httpRequest.getOrders();
    jsonOrders.forEach((o) {
      OrderModel order = OrderModel.fromJson(o);
      setState(() => ordersLst.add(order));
      if ((order.datePaid ?? '').isEmpty) setState(() => unpaidLst.add(order));
      if (order.status == 'processing') setState(() => processingLst.add(order));
      if (order.status == 'cancelled') setState(() => canceledLst.add(order));
      if (order.status == 'completed') setState(() => completedLst.add(order));
      if (order.status == 'pending') setState(() => pendingLst.add(order));
    });
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: const TextTitleMediumView('سفارشات', color: Colors.white),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.all(5),
                tabAlignment: TabAlignment.center,
                indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.white,
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
      ),
    );
  }
}
