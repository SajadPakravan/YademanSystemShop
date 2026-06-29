import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/database/cart_model.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/views/profile/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  HttpRequest httpRequest = HttpRequest();
  AppCache cache = AppCache();
  CustomerModel customer = CustomerModel();
  Box<CartModel> cartBox = Hive.box<CartModel>('cartBox');
  PageController pageCtrl = PageController(initialPage: 0);
  bool logged = false;
  bool loading = false;
  bool personalInfoAlert = false;
  bool addressAlert = false;
  bool cartAlert = false;
  int cartNumber = 0;

  signOut() async {
    await cache.clearCache();
    checkLogged();
  }

  checkLogged() async {
    setState(() => loading = true);
    String email = await cache.getString('email') ?? '';
    if (email.isNotEmpty) {
      checkCart();
      getCustomer();
    } else {
      setState(() {
        logged = false;
        loading = false;
      });
    }
  }

  getCustomer() async {
    setState(() => loading = true);
    dynamic jsonCustomer = await httpRequest.getCustomer(email: await cache.getString('email'));
    jsonCustomer.forEach((c) => setState(() => customer = CustomerModel.fromJson(c)));
    setState(() {
      personalInfoAlert = false;
      addressAlert = false;
    });
    await cache.setInt('id', customer.id!);
    if (customer.firstname!.isEmpty) {
      setState(() => personalInfoAlert = true);
    } else {
      await cache.setString('name', '${customer.firstname} ${customer.lastname}');
    }
    if (customer.billing!.city!.isEmpty) setState(() => addressAlert = true);
    setState(() {
      logged = true;
      loading = false;
    });
  }

  checkCart() {
    setState(() => cartAlert = false);
    if (cartBox.isNotEmpty) {
      setState(() {
        cartNumber = cartBox.length;
        cartAlert = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogged();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      context: context,
      customer: customer,
      getCustomer: getCustomer,
      logged: logged,
      signOut: signOut,
      pageCtrl: pageCtrl,
      checkLogged: checkLogged,
      loading: loading,
      personalInfoAlert: personalInfoAlert,
      addressAlert: addressAlert,
      cartAlert: cartAlert,
      cartNumber: cartNumber,
      checkCart: checkCart,
    );
  }
}
