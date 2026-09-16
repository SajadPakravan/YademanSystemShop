import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/screens/profile/cart/continue_payment_screen.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Box<CartModel> cartBox = Hive.box<CartModel>('cartBox');
  int totalPrice = 0;

  void increaseQuantity(int id) {
    final cart = cartBox.values.firstWhere((element) => element.id == id);
    cart.quantity++;
    cart.save();
    setTotalPrice();
  }

  void decreaseQuantity(int id) {
    final cart = cartBox.values.firstWhere((element) => element.id == id);
    if (cart.quantity > 1) {
      cart.quantity--;
      cart.save();
    } else {
      cart.delete();
    }
    setTotalPrice();
  }

  void setTotalPrice() {
    var value = 0;
    for (final cart in cartBox.values) {
      value += cart.price * cart.quantity;
    }
    if (mounted) setState(() => totalPrice = value);
  }

  @override
  void initState() {
    super.initState();
    setTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'سبد خرید'),
        body: ValueListenableBuilder(
          valueListenable: cartBox.listenable(),
          builder: (context, Box<CartModel> box, _) {
            if (box.isEmpty) return const Center(child: TextBodyMediumView('سبد خرید شما خالی است'));

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: r.space(6)),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final cart = box.getAt(index)!;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: r.pageHorizontalPadding, vertical: r.space(6)),
                  padding: EdgeInsets.all(r.space(10)),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(r.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: CachedNetworkImage(
                          imageUrl: cart.image,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) => Icon(Icons.image_not_supported_outlined, color: colors.textMuted, size: r.icon(42)),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.space(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBodyMediumView(cart.name, fontWeight: FontWeight.bold, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                              SizedBox(height: r.space(10)),
                              TextBodyMediumView('${cart.price.toString().toPersianDigit().seRagham()} تومان', fontWeight: FontWeight.bold),
                              SizedBox(height: r.space(16)),
                              IntrinsicWidth(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colors.surfaceVariant,
                                    border: Border.all(color: colors.border),
                                    borderRadius: BorderRadius.circular(r.radius(10)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add_circle, color: AppColors.primary, size: r.icon(28)),
                                        onPressed: () => increaseQuantity(cart.id),
                                      ),
                                      SizedBox(width: r.space(5)),
                                      TextBodyMediumView(cart.quantity.toString().toPersianDigit(), fontSize: 18, fontWeight: FontWeight.bold),
                                      SizedBox(width: r.space(5)),
                                      IconButton(
                                        icon: Icon(cart.quantity == 1 ? Icons.delete_outline : Icons.remove_circle, color: AppColors.primary, size: r.icon(28)),
                                        onPressed: () => decreaseQuantity(cart.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: totalPrice != 0 ? _cartPrice(context) : null,
      ),
    );
  }

  Widget _cartPrice(BuildContext context) {
    final colors = context.appColors;
    final r = context.responsive;

    return Visibility(
      visible: cartBox.isNotEmpty,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.all(r.space(10)),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.divider, width: 2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await Get.to(
                      ContinuePaymentScreen(cartBox: cartBox),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                      arguments: Get.arguments,
                    );
                    setTotalPrice();
                  },
                  child: const TextBodyLargeView('ادامه فرآیند خرید', color: AppColors.onBrand),
                ),
              ),
              SizedBox(width: r.space(18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const TextBodyLargeView('جمع کل سبد خرید'),
                  SizedBox(height: r.space(6)),
                  TextBodyLargeView('${totalPrice.toString().toPersianDigit().seRagham()} تومان', textAlign: TextAlign.left, fontWeight: FontWeight.bold),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
