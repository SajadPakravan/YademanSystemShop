import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/screens/main_screen.dart';
import 'package:yad_sys/screens/profile/address/address_screen.dart';
import 'package:yad_sys/screens/profile/orders/order_screen.dart';
import 'package:yad_sys/themes/color_style.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/tools/go_page.dart';
import 'package:yad_sys/widgets/app_bar_view.dart';
import 'package:yad_sys/widgets/loading.dart';
import 'package:yad_sys/widgets/snack_bar_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_large_view.dart';
import 'package:yad_sys/widgets/text_views/text_body_medium_view.dart';

class ContinuePaymentScreen extends StatefulWidget {
  const ContinuePaymentScreen({super.key, required this.cartBox});

  final Box<CartModel> cartBox;

  @override
  State<ContinuePaymentScreen> createState() => _ContinuePaymentScreenState();
}

class _ContinuePaymentScreenState extends State<ContinuePaymentScreen> {
  HttpRequest httpRequest = HttpRequest();
  AppCache cache = AppCache();
  CustomerModel customer = CustomerModel();
  Box<CartModel> cartBox = Hive.box<CartModel>('cartBox');
  bool loading = false;
  bool addressAlert = false;
  int totalCart = 0;
  bool najafabad = false;
  bool esfahan = false;
  bool otherCity = false;
  int selectMethod = 0;
  int shippingTotal = 0;
  int najafabadPrice = 40000;
  int esfahanPrice = 50000;
  int totalPrice = 0;
  List products = [];

  getCustomer() async {
    setState(() => loading = true);
    dynamic jsonCustomer = await httpRequest.getCustomer(email: await cache.getString('email'));
    jsonCustomer.forEach((c) => setState(() => customer = CustomerModel.fromJson(c)));
    if (customer.billing!.city!.isEmpty) {
      setState(() => addressAlert = true);
    } else {
      setState(() => addressAlert = false);
    }
    setState(() => loading = false);
    setDetailPrice();
  }

  increaseQuantity(int id) {
    final cart = widget.cartBox.values.firstWhere((element) => element.id == id);
    cart.quantity++;
    cart.save();
    setState(() {});
    setDetailPrice();
  }

  decreaseQuantity(int id) {
    final cart = widget.cartBox.values.firstWhere((element) => element.id == id);
    if (cart.quantity > 1) {
      cart.quantity--;
      cart.save();
    }
    setState(() {});
    setDetailPrice();
  }

  setDetailPrice() async {
    totalCart = 0;
    shippingTotal = 0;
    setState(() => products.clear());
    await shippingMethod();
    for (int i = 0; i < widget.cartBox.length; i++) {
      CartModel cart = widget.cartBox.getAt(i)!;
      setShippingTotal(cart);
      setState(() {
        totalCart += cart.price * cart.quantity;
        totalPrice = totalCart + shippingTotal;
        products.add({'product_id': cart.id, 'quantity': cart.quantity});
      });
    }
  }

  shippingMethod() {
    if (!addressAlert) {
      List<String> n = ['8511', '8513', '8514', '8515', '8516', '8517', '8518', '8519'];
      List<String> e = ['811', '813', '814', '815', '816', '817', '818', '819'];
      String postcode = customer.billing!.postcode!;
      setState(() {
        najafabad = false;
        esfahan = false;
        otherCity = false;
      });
      for (int i = 0; i < n.length; i++) {
        if (postcode.startsWith(n[i])) {
          setState(() => najafabad = true);
          if (selectMethod == 2) setState(() => shippingTotal = najafabadPrice);
          break;
        }
      }
      if (!najafabad) {
        for (int i = 0; i < e.length; i++) {
          if (postcode.startsWith(e[i])) {
            setState(() => esfahan = true);
            if (selectMethod == 2) setState(() => shippingTotal = esfahanPrice);
            break;
          }
        }
      }
      if (!najafabad && !esfahan) setState(() => otherCity = true);
    }
  }

  setShippingTotal(CartModel cart) {
    if (otherCity) {
      setState(() => selectMethod = 1);
      int shPrice = 0;
      switch (cart.shippingClass) {
        case 'small':
          {
            shPrice = 50000;
            break;
          }
        case 'medium':
          {
            shPrice = 70000;
            break;
          }
        case 'big':
          {
            shPrice = 90000;
            break;
          }
      }
      shPrice *= cart.quantity;
      setState(() => shippingTotal += shPrice);
    }
  }

  @override
  void initState() {
    super.initState();
    getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarView(title: 'تاید آدرس و فاکتور'),
        body: loading ? const Loading() : SingleChildScrollView(child: Column(children: [addressView(), cartView(), priceView()])),
        bottomNavigationBar: Visibility(visible: !loading, child: cartPrice()),
      ),
    );
  }

  addressView() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextBodyMediumView('ارسال به', color: Colors.grey.shade700),
        ),
        subtitle: addressAlert
            ? Column(
                children: [
                  const TextBodyMediumView('لطفا آدرس خود را وارد کنید'),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextButton.icon(
                      label: const TextBodyMediumView('وارد کردن آدرس و مشخصات', color: Colors.indigo),
                      icon: const Icon(Icons.keyboard_arrow_left),
                      onPressed: () async {
                        await zoomToPage(const AddressScreen(), arguments: customer);
                        getCustomer();
                      },
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextBodyMediumView(
                    '${customer.shipping!.state!}، ${customer.shipping!.city!}، ${customer.shipping!.address1!}، ${customer.shipping!.address2!}',
                    height: 2,
                  ),
                  TextBodyMediumView(customer.shipping!.postcode!.toString().toPersianDigit(), height: 2),
                  TextBodyMediumView('${customer.shipping!.firstname!} ${customer.shipping!.lastname!}', height: 2),
                  Align(
                    alignment: Alignment.center,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextButton.icon(
                        label: const TextBodyMediumView('تغییر آدرس و مشخصات', color: Colors.indigo),
                        icon: const Icon(Icons.keyboard_arrow_left),
                        onPressed: () async {
                          await zoomToPage(const AddressScreen(), arguments: customer);
                          getCustomer();
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  cartView() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 20),
          child: TextBodyMediumView(
            '${widget.cartBox.length.toString().toPersianDigit()} عدد کالا در سبد خرید شما',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: SizedBox(
          height: MediaQuery.of(context).size.height * 0.23,
          child: ValueListenableBuilder(
            valueListenable: widget.cartBox.listenable(),
            builder: (context, Box<CartModel> box, _) {
              return ListView.builder(
                itemCount: box.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  CartModel cart = box.getAt(index)!;
                  return Row(
                    children: [
                      Column(
                        children: [
                          Expanded(child: CachedNetworkImage(imageUrl: cart.image, fit: BoxFit.contain)),
                          const SizedBox(height: 20),
                          Row(
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
                                icon: const Icon(Icons.remove_circle, color: Colors.indigo, size: 30),
                                onPressed: cart.quantity == 1 ? null : () => decreaseQuantity(cart.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Visibility(
                        visible: index + 1 != widget.cartBox.length,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.26,
                              width: 1,
                              decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black38))),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  priceView() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: TextBodyLargeView('جزئیات قیمت', fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextBodyMediumView('جمع کل سبد خرید'),
                TextBodyMediumView(
                  '${totalCart.toString().toPersianDigit().seRagham()} تومان',
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: TextBodyMediumView('حمل و نقل')),
                  addressAlert
                      ? const TextBodyMediumView('نامشخص', color: Colors.red)
                      : najafabad || esfahan
                          ? Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  method(
                                    value: 1,
                                    title: 'تحویل حضوری',
                                    subTitle: 'رایگان',
                                    onSelect: () {
                                      setState(() => shippingTotal = 0);
                                      setDetailPrice();
                                    },
                                  ),
                                  method(
                                    value: 2,
                                    title: najafabad ? 'تحویل در نجف‌آباد' : 'تحویل در اصفهان',
                                    subTitle: najafabad
                                        ? najafabadPrice.toString().toPersianDigit().seRagham()
                                        : esfahanPrice.toString().toPersianDigit().seRagham(),
                                    onSelect: () {
                                      if (selectMethod == 2) {
                                        if (najafabad) {
                                          setState(() => shippingTotal = najafabadPrice);
                                        } else {
                                          setState(() => shippingTotal = esfahanPrice);
                                        }
                                        setDetailPrice();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              flex: 2,
                              child: ListTile(
                                title: const TextBodyMediumView('پست پیشتاز', textAlign: TextAlign.left),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: TextBodyMediumView(
                                    '${shippingTotal.toString().toPersianDigit().seRagham()} تومان',
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextBodyMediumView('مبلغ قابل پرداخت'),
                TextBodyMediumView(
                  '${totalPrice.toString().toPersianDigit().seRagham()} تومان',
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  method({required int value, required String title, required String subTitle, required Function onSelect}) {
    return InkWell(
      child: RadioListTile<int>(
        value: value,
        groupValue: selectMethod,
        title: TextBodyMediumView(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: TextBodyMediumView(subTitle, fontWeight: FontWeight.bold, textAlign: TextAlign.left),
        ),
        onChanged: (v) {
          setState(() => selectMethod = v!);
          onSelect();
        },
      ),
      onTap: () {
        setState(() => selectMethod = value);
        onSelect();
      },
    );
  }

  cartPrice() {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IntrinsicWidth(
              child: EasyButton(
                idleStateWidget: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextBodyLargeView('پرداخت و ثبت سفارش', color: Colors.white),
                ),
                loadingStateWidget: const Padding(padding: EdgeInsets.all(5), child: Loading(color: Colors.white)),
                buttonColor: ColorStyle.blueFav,
                borderRadius: 10,
                onPressed: () async {
                  if (selectMethod != 0) {
                    dynamic jsonOrder = await httpRequest.createOrder(
                      context: context,
                      customerId: customer.id!,
                      firstname: customer.billing!.firstname!,
                      lastname: customer.billing!.lastname!,
                      email: customer.billing!.email!,
                      phone: customer.billing!.phone!,
                      company: customer.billing!.company!,
                      state: customer.billing!.state!,
                      city: customer.billing!.city!,
                      street: customer.billing!.address1!,
                      number: customer.billing!.address2!,
                      postcode: customer.billing!.postcode!,
                      products: products,
                      shippingTotal: shippingTotal,
                    );
                    if (jsonOrder != false) {
                      if (mounted) SnackBarView.show(context, 'سفارش شما ثبت شد');
                      await cartBox.clear();
                      Get.offAll(const MainScreen(pageIndex: 3), transition: Transition.zoom, duration: const Duration(milliseconds: 300));
                      WidgetsBinding.instance.addPostFrameCallback((_) => zoomToPage(() => const OrderScreen()));
                    }
                  } else {
                    SnackBarView.show(context, 'لطفا روش حمل و نقل را انتخاب کنید');
                  }
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const TextBodyLargeView('مبلغ قابل پرداخت'),
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
    );
  }
}
