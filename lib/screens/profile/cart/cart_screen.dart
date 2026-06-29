import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/screens/profile/cart/continue_payment_screen.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Box<CartModel> cartBox = Hive.box<CartModel>('cartBox');
  int totalPrice = 0;

  increaseQuantity(int id) {
    final cart = cartBox.values.firstWhere((element) => element.id == id);
    cart.quantity++;
    cart.save();
    setState(() {});
    setTotalPrice();
  }

  decreaseQuantity(int id) {
    final cart = cartBox.values.firstWhere((element) => element.id == id);
    if (cart.quantity > 1) {
      cart.quantity--;
      cart.save();
    } else {
      cart.delete();
    }
    setState(() {});
    setTotalPrice();
  }

  setTotalPrice() {
    setState(() => totalPrice = 0);
    for (int i = 0; i < cartBox.length; i++) {
      CartModel cart = cartBox.getAt(i)!;
      setState(() => totalPrice += cart.price * cart.quantity);
    }
  }

  @override
  void initState() {
    super.initState();
    setTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'سبد خرید'),
        body: ValueListenableBuilder(
          valueListenable: cartBox.listenable(),
          builder: (context, Box<CartModel> box, _) {
            if (box.isEmpty) return const Center(child: TextBodyMediumView('سبد خرید شما خالی است'));
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                CartModel cart = box.getAt(index)!;
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Flexible(flex: 1, child: CachedNetworkImage(imageUrl: cart.image, fit: BoxFit.contain)),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBodyMediumView(cart.name, fontWeight: FontWeight.bold, textAlign: TextAlign.center, maxLines: 1),
                              const SizedBox(height: 10),
                              TextBodyMediumView('${cart.price.toString().toPersianDigit().seRagham()} تومان', fontWeight: FontWeight.bold),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.center,
                                child: IntrinsicWidth(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black45),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 30),
                                          onPressed: () => increaseQuantity(cart.id),
                                        ),
                                        const SizedBox(width: 10),
                                        TextBodyMediumView(cart.quantity.toString().toPersianDigit(), fontSize: 18),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon: Icon(
                                            cart.quantity == 1 ? Icons.delete : Icons.remove_circle,
                                            color: Colors.indigo,
                                            size: 30,
                                          ),
                                          onPressed: () => decreaseQuantity(cart.id),
                                        ),
                                      ],
                                    ),
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
        bottomNavigationBar: totalPrice != 0 ? cartPrice() : null,
      ),
    );
  }

  cartPrice() {
    return Visibility(
      visible: cartBox.isNotEmpty,
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                onPressed: () async {
                  await Get.to(
                    ContinuePaymentScreen(cartBox: cartBox),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 300),
                    arguments: Get.arguments,
                  );
                  setTotalPrice();
                },
                child: const TextBodyLargeView('ادامه فرآیند خرید', color: Colors.white),
              ),
              Column(
                children: [
                  const TextBodyLargeView('جمع کل سبد خرید'),
                  const SizedBox(height: 10),
                  TextBodyLargeView(
                    '${totalPrice.toString().toPersianDigit().seRagham()} تومان',
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
