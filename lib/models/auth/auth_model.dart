class AuthModel {
  const AuthModel({required this.id, required this.username, required this.email, required this.phone, required this.token});

  final int id;
  final String username;
  final String email;
  final String phone;
  final String token;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(id: json['id'], username: json['username'], email: json['email'], phone: json['phone'], token: json['token']);
  }

  String get contact {
    if (email.isNotEmpty) return email;
    if (phone.isNotEmpty) return phone;
    return username;
  }
}
