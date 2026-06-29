class CustomerModel {
  int? id;
  String? email;
  String? firstname;
  String? lastname;
  String? role;
  String? username;
  String? avatarUrl;
  Billing? billing;
  Shipping? shipping;

  CustomerModel({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.role,
    this.username,
    this.avatarUrl,
    this.billing,
    this.shipping,
  });

  CustomerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstname = json['first_name'];
    lastname = json['last_name'];
    role = json['role'];
    username = json['username'];
    avatarUrl = json['avatar_url'];
    billing = json['billing'] != null ? Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['first_name'] = firstname;
    data['last_name'] = lastname;
    data['role'] = role;
    data['username'] = username;
    data['avatar_url'] = avatarUrl;
    if (billing != null) data['billing'] = billing!.toJson();
    if (shipping != null) data['shipping'] = shipping!.toJson();
    return data;
  }
}

class Billing {
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? company;
  String? country;
  String? state;
  String? city;
  String? address1;
  String? address2;
  String? postcode;

  Billing({
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.company,
    this.country,
    this.state,
    this.city,
    this.address1,
    this.address2,
    this.postcode,
  });

  Billing.fromJson(Map<String, dynamic> json) {
    firstname = json['first_name'];
    lastname = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    company = json['company'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    postcode = json['postcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstname;
    data['last_name'] = lastname;
    data['email'] = email;
    data['phone'] = phone;
    data['company'] = company;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['postcode'] = postcode;
    return data;
  }
}

class Shipping {
  String? firstname;
  String? lastname;
  String? phone;
  String? company;
  String? country;
  String? state;
  String? city;
  String? address1;
  String? address2;
  String? postcode;

  Shipping({
    this.firstname,
    this.lastname,
    this.phone,
    this.company,
    this.country,
    this.state,
    this.city,
    this.address1,
    this.address2,
    this.postcode,
  });

  Shipping.fromJson(Map<String, dynamic> json) {
    firstname = json['first_name'];
    lastname = json['last_name'];
    phone = json['phone'];
    company = json['company'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    postcode = json['postcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstname;
    data['last_name'] = lastname;
    data['phone'] = phone;
    data['company'] = company;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['postcode'] = postcode;
    return data;
  }
}
