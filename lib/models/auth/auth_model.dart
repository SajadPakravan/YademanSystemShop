import 'package:yad_sys/models/customer_model.dart';

class AuthModel {
  const AuthModel({required this.success, required this.token, required this.user});

  final bool success;
  final String token;
  final CustomerModel user;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(success: json['success'], token: json['token'], user: CustomerModel.fromJson(json['user']));
  }
}
