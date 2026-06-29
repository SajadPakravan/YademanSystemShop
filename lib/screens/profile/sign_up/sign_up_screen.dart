import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:yad_sys/connections/http_request.dart';
import 'package:yad_sys/tools/app_cache.dart';
import 'package:yad_sys/views/profile/sign_up/sign_up_view.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.pageCtrl, required this.checkLogged});

  final PageController pageCtrl;
  final Function() checkLogged;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  HttpRequest httpRequest = HttpRequest();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController rePassCtrl = TextEditingController();
  bool obscureText = true;
  bool showPass = false;
  bool emailErrVis = false;
  String emailErrStr = "";
  bool passErrVis = false;
  String passErrStr = "";
  bool rePassErrVis = false;
  String rePassErrStr = "";

  showPassFun(v) {
    if (v) {
      setState(() {
        showPass = v;
        obscureText = false;
      });
    } else {
      setState(() {
        showPass = v;
        obscureText = true;
      });
    }
  }

  signUpFun() async {
    setState(() {
      emailErrVis = false;
      passErrVis = false;
      rePassErrVis = false;
    });

    if (emailCtrl.text.isEmpty) {
      setState(() {
        emailErrVis = true;
        emailErrStr = 'لطفا ایمل را وارد کنید';
      });
    } else {
      if (!EmailValidator.validate(emailCtrl.text, true)) {
        setState(() {
          emailErrVis = true;
          emailErrStr = 'ایمیل وارد شده معتبر نیست';
        });
      }
    }

    if (passCtrl.text.isEmpty) {
      setState(() {
        passErrVis = true;
        passErrStr = 'لطفا کلمه عبور را وارد کنید';
      });
    }

    if (rePassCtrl.text.isEmpty) {
      setState(() {
        rePassErrVis = true;
        rePassErrStr = 'لطفا تکرار کلمه عبور را وارد کنید';
      });
    } else if (rePassCtrl.text != passCtrl.text) {
      setState(() {
        rePassErrVis = true;
        rePassErrStr = 'تکرار کلمه عبور با کلمه عبور برابر نیست';
      });
    }

    if (!emailErrVis && !passErrVis && !rePassErrVis) {
      await Future<void>.delayed(const Duration(seconds: 3));
      AppCache cache = AppCache();
      if (mounted) {
        dynamic jsonSignUp = await httpRequest.signUp(context: context, email: emailCtrl.text, password: passCtrl.text);
        if (jsonSignUp != false) {
          if (mounted) {
            dynamic jsonSignIn = await httpRequest.signIn(context: context, email: emailCtrl.text, password: passCtrl.text);
            if (jsonSignIn != false) {
              await cache.setString('token', jsonSignIn['token']);
              await cache.setString('email', jsonSignIn['user_email']);
              widget.checkLogged();
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignUpView(
      context: context,
      emailCtrl: emailCtrl,
      passCtrl: passCtrl,
      rePassCtrl: rePassCtrl,
      obscureText: obscureText,
      showPass: showPass,
      showPassFun: showPassFun,
      signUpFun: signUpFun,
      emailErrVis: emailErrVis,
      emailErrStr: emailErrStr,
      passErrVis: passErrVis,
      passErrStr: passErrStr,
      rePassErrVis: rePassErrVis,
      rePassErrStr: rePassErrStr,
      pageCtrl: widget.pageCtrl,
    );
  }
}
