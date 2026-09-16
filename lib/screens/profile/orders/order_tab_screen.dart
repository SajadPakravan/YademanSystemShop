import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/models/order_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class OrderTabScreen extends StatelessWidget {
  const OrderTabScreen({super.key, required this.list});

  final List<OrderModel> list;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return list.isEmpty
        ? const Center(child: TextBodyMediumView('سفارشی وجود ندارد'))
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: r.space(6)),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final order = list[index];
              final itemsLst = order.lineItems!;
              final date = order.dateCreated.toString().toPersianDate();
              final t = order.dateCreated.toString().split('T');
              final h = t[1].split(':')[0];
              final m = t[1].split(':')[1];
              final time = '$h:$m'.toPersianDigit();

              return Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(r.cardRadius),
                ),
                margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(6)),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Padding(
                    padding: EdgeInsets.fromLTRB(r.space(10), r.space(5), r.space(10), r.space(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBodyMediumView('کد سفارش: ${order.id.toString().toPersianDigit()}'),
                        SizedBox(height: r.space(8)),
                        TextBodyMediumView('زمان ثبت: $date - $time'),
                        SizedBox(height: r.space(8)),
                        TextBodyMediumView('مجموع: ${(order.total).toString().toPersianDigit().seRagham()} تومان', fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                  subtitle: SizedBox(
                    height: r.percentHeight(0.1, min: 72, max: 108),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemsLst.length,
                      itemBuilder: (context, itemIndex) {
                        final item = itemsLst[itemIndex];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: r.space(10)),
                          decoration: itemIndex + 1 != itemsLst.length
                              ? BoxDecoration(border: Border(left: BorderSide(color: colors.divider)))
                              : null,
                          child: CachedNetworkImage(
                            imageUrl: item.image!.src!,
                            errorWidget: (_, _, _) => Icon(Icons.image_not_supported_outlined, color: colors.textMuted),
                          ),
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
