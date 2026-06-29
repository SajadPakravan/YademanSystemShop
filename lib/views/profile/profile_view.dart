import 'package:flutter/material.dart';
import 'package:yad_sys/models/customer_model.dart';
import 'package:yad_sys/screens/profile/sign_in/sign_in_screen.dart';
import 'package:yad_sys/screens/profile/sign_up/sign_up_screen.dart';
import 'package:yad_sys/views/profile/logged/logged_view.dart';
import 'package:yad_sys/widgets/loading.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.context,
    required this.customer,
    required this.getCustomer,
    required this.logged,
    required this.signOut,
    required this.pageCtrl,
    required this.checkLogged,
    required this.loading,
    required this.personalInfoAlert,
    required this.addressAlert,
    required this.cartAlert,
    required this.cartNumber,
    required this.checkCart,
  });

  final BuildContext context;
  final CustomerModel customer;
  final Function() getCustomer;
  final bool logged;
  final PageController pageCtrl;
  final Function() checkLogged;
  final void Function() signOut;
  final void Function() checkCart;
  final bool loading;
  final bool personalInfoAlert;
  final bool addressAlert;
  final bool cartAlert;
  final int cartNumber;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : logged
            ? LoggedView(
                context: context,
                customer: customer,
                getCustomer: getCustomer,
                signOut: signOut,
                personalInfoAlert: personalInfoAlert,
                addressAlert: addressAlert,
                cartAlert: cartAlert,
                cartNumber: cartNumber,
                checkCart: checkCart,
              )
            : Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  toolbarHeight: 100,
                  title: const Icon(Icons.account_circle, color: Colors.grey, size: 100),
                ),
                body: PageView(
                  controller: pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SignInScreen(pageCtrl: pageCtrl, checkLogged: checkLogged),
                    SignUpScreen(pageCtrl: pageCtrl, checkLogged: checkLogged),
                  ],
                ),
              );
  }
}
