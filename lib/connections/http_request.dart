import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpRequest {
  HttpRequest();

  final String _urlMain = 'yademansystem.ir';

  String get _urlHome => 'https://$_urlMain/wp-json/app-api/v1/home';

  String get _urlProducts => 'https://$_urlMain/wp-json/app-api/v1/products/';

  String get _urlCategories => 'https://$_urlMain/wp-json/app-api/v1/categories/';

  String get _urlLogin => 'https://$_urlMain/wp-json/app-api/v1/auth/login';

  String get _urlRegister => 'https://$_urlMain/wp-json/app-api/v1/auth/register';

  String get _urlCustomer => 'https://$_urlMain/wp-json/app-api/v1/customers';

  String get _urlOrders => 'https://$_urlMain/wp-json/app-api/v1/orders';

  String get _urlCart => 'https://$_urlMain/wp-json/app-api/v1/cart';

  String get _urlFavorites => 'https://$_urlMain/wp-json/app-api/v1/favorites';

  String get _urlViewedProducts => 'https://$_urlMain/wp-json/app-api/v1/viewed-products';

  String get _urlComments => 'https://$_urlMain/wp-json/app-api/v1/comments';

  Future<dynamic> _getPublicRequest({required String url}) async {
    const headers = <String, String>{'accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'};

    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 25));

      if (kDebugMode) print('Public GET >>>> ${response.request}');

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (kDebugMode) print('JSON >>>> $decoded');
        return decoded;
      }

      if (kDebugMode) {
        print('Status Code >>>> ${response.statusCode}');
        print('JSON ERROR >>>> $decoded');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('PUBLIC GET ERROR >>>> $e');
      return false;
    }
  }

  Future<dynamic> _getAuthorizedRequest({required String url, required String token}) async {
    final headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 25));
      if (kDebugMode) print('Authorized GET >>>> ${response.request}');

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (kDebugMode) print('JSON >>>> $decoded');
        return decoded;
      }

      if (kDebugMode) {
        print('Status Code >>>> ${response.statusCode}');
        print('JSON ERROR >>>> $decoded');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('AUTHORIZED GET ERROR >>>> $e');
      return false;
    }
  }

  Future<dynamic> _postPublicRequest({required String url, required Map<String, dynamic> body}) async {
    const headers = <String, String>{'accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'};

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 25));

      if (kDebugMode) print('Public POST >>>> ${response.request}');

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (kDebugMode) {
        print('Status Code >>>> ${response.statusCode}');
        print('JSON >>>> $decoded');
      }

      return decoded;
    } catch (e) {
      if (kDebugMode) print('PUBLIC POST ERROR >>>> $e');
      return false;
    }
  }

  Future<dynamic> getHome() async => _getPublicRequest(url: _urlHome);

  Future<dynamic> getProducts({
    int page = 1,
    int perPage = 20,
    String search = '',
    List<int> categories = const <int>[],
    List<int> brands = const <int>[],
    Map<int, List<int>> attributes = const <int, List<int>>{},
    int? minPrice,
    int? maxPrice,
    bool? onSale,
    String orderby = 'date',
    String order = 'desc',
  }) async {
    final query = <String, String>{'page': '$page', 'per_page': '$perPage', 'orderby': orderby, 'order': order};

    if (search.trim().isNotEmpty) query['search'] = search.trim();
    if (categories.isNotEmpty) query['category'] = categories.join(',');
    if (brands.isNotEmpty) query['brand'] = brands.join(',');
    if (minPrice != null) query['min_price'] = '$minPrice';
    if (maxPrice != null) query['max_price'] = '$maxPrice';
    if (onSale != null) query['on_sale'] = onSale ? 'true' : 'false';

    for (final entry in attributes.entries) {
      if (entry.value.isEmpty) continue;
      query['attributes[${entry.key}]'] = entry.value.join(',');
    }

    final uri = Uri.parse(_urlProducts).replace(queryParameters: query);
    return _getPublicRequest(url: uri.toString());
  }

  Future<dynamic> getProduct({required int id}) async => _getPublicRequest(url: '$_urlProducts$id');

  Future<dynamic> getCategories() async => _getPublicRequest(url: _urlCategories);

  Future<dynamic> getCategory({required int id}) async => _getPublicRequest(url: '$_urlCategories$id');

  Future<dynamic> register({required String identifier, required String password}) =>
      _postPublicRequest(url: _urlRegister, body: <String, dynamic>{'identifier': identifier.trim(), 'password': password});

  Future<dynamic> login({required String identifier, required String password}) =>
      _postPublicRequest(url: _urlLogin, body: <String, dynamic>{'identifier': identifier.trim(), 'password': password});

  Future<dynamic> getCustomer({required String token}) async => _getAuthorizedRequest(url: _urlCustomer, token: token);

  Future<dynamic> getOrders({required String token}) async => _getAuthorizedRequest(url: _urlOrders, token: token);

  Future<dynamic> getCart({required String token}) async => _getAuthorizedRequest(url: _urlCart, token: token);

  Future<dynamic> getFavorites({required String token}) async => _getAuthorizedRequest(url: _urlFavorites, token: token);

  Future<dynamic> getViewedProducts({required String token}) async => _getAuthorizedRequest(url: _urlViewedProducts, token: token);

  Future<dynamic> getCustomerComments({required String token}) async => _getAuthorizedRequest(url: _urlComments, token: token);

  Future<dynamic> signUp({required BuildContext context, required String email, required String password}) => register(identifier: email, password: password);

  Future<dynamic> signIn({required BuildContext context, required String email, required String password}) => login(identifier: email, password: password);
}
