class AuthModel {
  const AuthModel({required this.id, required this.username, required this.email, required this.mobile, required this.token});

  final int id;
  final String username;
  final String email;
  final String mobile;
  final String token;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(id: json['id'], username: json['username'], email: json['email'], mobile: json['phone'], token: json['token']);
  }

  String get contact {
    if (email.isNotEmpty) return email;
    if (mobile.isNotEmpty) return mobile;
    return username;
  }
}
