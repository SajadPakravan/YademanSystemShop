import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/account/account_empty_state.dart';
import 'package:yad_sys/widgets/account/customer_product_row_card.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key, required this.items});
  final List<CustomerProductItemModel> items;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: const AppBarView(title: 'علاقه‌مندی‌ها'),
      body: items.isEmpty
          ? const AccountEmptyState(icon: Icons.favorite_border_rounded, title: 'لیست علاقه‌مندی خالی است', message: 'محصولاتی که دوست دارید را به علاقه‌مندی‌ها اضافه کنید.')
          : ListView.separated(
              padding: EdgeInsets.all(r.pageHorizontalPadding),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: r.space(10)),
              itemBuilder: (context, index) => CustomerProductRowCard(item: items[index], showQuantity: false),
            ),
    );
  }
}
