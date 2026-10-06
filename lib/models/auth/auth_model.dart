import 'package:yad_sys/models/customer_model.dart';

class AuthModel {
  const AuthModel({required this.token, required this.customer});

  final String token;
  final CustomerModel customer;

  int get id => customer.id;

  String get username => customer.username;

  String get firstName => customer.firstName;

  String get lastName => customer.lastName;

  String get displayName => customer.displayName;

  String get email => customer.email;

  String get phone => customer.phone;

  String get avatar => customer.avatar;

  String get dateCreated => customer.dateCreated;

  int get addressCount => customer.addressCount;

  int get ordersCount => customer.ordersCount;

  int get cartCount => customer.cartCount;

  int get commentsCount => customer.commentsCount;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    if (json['user'] is Map) {
      return AuthModel(token: _string(json['token'] ?? json['access_token']), customer: CustomerModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)));
    }

    final source = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;
    return AuthModel(token: _string(source['token'] ?? source['access_token'] ?? json['token']), customer: CustomerModel.fromJson(source));
  }

  AuthModel copyWith({String? token, CustomerModel? customer}) => AuthModel(token: token ?? this.token, customer: customer ?? this.customer);

  String get contact {
    if (email.isNotEmpty) return email;
    if (phone.isNotEmpty) return phone;
    return username;
  }
}

String _string(dynamic value) => value?.toString() ?? '';
