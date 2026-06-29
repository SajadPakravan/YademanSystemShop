import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/order_model.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class OrderTabScreen extends StatelessWidget {
  const OrderTabScreen({super.key, required this.list});

  final List<OrderModel> list;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return list.isEmpty
        ? const Center(child: TextBodyMediumView('سفارشی وجود ندارد'))
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              OrderModel order = list[index];
              List<LineItems> itemsLst = order.lineItems!;
              String date = order.dateCreated.toString().toPersianDate();
              List<String> t = order.dateCreated.toString().split('T');
              String h = t[1].split(':')[0];
              String m = t[1].split(':')[1];
              String time = '$h:$m'.toPersianDigit();
              return Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black87), borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBodyMediumView('کد سفارش: ${order.id.toString().toPersianDigit()}'),
                        const SizedBox(height: 10),
                        TextBodyMediumView('زمان ثبت: $date - $time'),
                        const SizedBox(height: 10),
                        TextBodyMediumView('مجموع: ${(order.total).toString().toPersianDigit().seRagham()} تومان'),
                      ],
                    ),
                  ),
                  subtitle: SizedBox(
                    height: height * 0.1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemsLst.length,
                      itemBuilder: (context, itemIndex) {
                        LineItems item = itemsLst[itemIndex];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: itemIndex + 1 != itemsLst.length
                              ? const BoxDecoration(border: Border(left: BorderSide(color: Colors.black38)))
                              : null,
                          child: CachedNetworkImage(imageUrl: item.image!.src!),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
  }
}
