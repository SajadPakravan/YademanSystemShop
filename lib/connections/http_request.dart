import 'dart:convert';

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

  static const Map<String, String> _jsonHeaders = <String, String>{'accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'};

  Map<String, String> _authorizedHeaders(String token) => <String, String>{..._jsonHeaders, 'Authorization': 'Bearer $token'};

  dynamic _decodeResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (body.isEmpty) {
      return <String, dynamic>{'success': response.statusCode >= 200 && response.statusCode < 300, 'status_code': response.statusCode};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final result = Map<String, dynamic>.from(decoded);
        result.putIfAbsent('status_code', () => response.statusCode);
        return result;
      }
      return decoded;
    } catch (_) {
      return <String, dynamic>{'success': false, 'message': body, 'status_code': response.statusCode};
    }
  }

  Future<dynamic> _getPublicRequest({required String url}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _jsonHeaders).timeout(const Duration(seconds: 25));
      if (kDebugMode) print('Public GET >>>> ${response.request}');

      final decoded = _decodeResponse(response);
      if (kDebugMode) {
        print('Status Code >>>> ${response.statusCode}');
        print('JSON >>>> $decoded');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) return decoded;
      return decoded;
    } catch (e) {
      if (kDebugMode) print('PUBLIC GET ERROR >>>> $e');
      return false;
    }
  }

  Future<dynamic> _authorizedJsonRequest({
    required String method,
    required String url,
    required String token,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 35),
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = _authorizedHeaders(token);
      final encodedBody = body == null ? null : jsonEncode(body);

      late final http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody).timeout(timeout);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: encodedBody).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: encodedBody).timeout(timeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      final decoded = _decodeResponse(response);
      if (kDebugMode) {
        print('Authorized ${method.toUpperCase()} >>>> ${response.request}');
        print('Status Code >>>> ${response.statusCode}');
        print('JSON >>>> $decoded');
      }
      return decoded;
    } catch (e) {
      if (kDebugMode) print('AUTHORIZED ${method.toUpperCase()} ERROR >>>> $e');
      return false;
    }
  }

  Future<dynamic> _postPublicRequest({required String url, required Map<String, dynamic> body}) async {
    try {
      final response = await http.post(Uri.parse(url), headers: _jsonHeaders, body: jsonEncode(body)).timeout(const Duration(seconds: 25));

      final decoded = _decodeResponse(response);
      if (kDebugMode) {
        print('Public POST >>>> ${response.request}');
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

  Future<dynamic> getCustomer({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlCustomer, token: token);

  /// Partial profile update. Only changed fields should be supplied by the caller.
  Future<dynamic> updateCustomer({required String token, required Map<String, dynamic> changes}) =>
      _authorizedJsonRequest(method: 'PATCH', url: _urlCustomer, token: token, body: changes, timeout: const Duration(seconds: 60));

  Future<dynamic> getOrders({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlOrders, token: token);

  Future<dynamic> createOrder({required String token, required Map<String, dynamic> body}) =>
      _authorizedJsonRequest(method: 'POST', url: _urlOrders, token: token, body: body);

  Future<dynamic> updateOrder({required String token, required int orderId, required Map<String, dynamic> body}) =>
      _authorizedJsonRequest(method: 'PATCH', url: '$_urlOrders/$orderId', token: token, body: body);

  Future<dynamic> getCart({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlCart, token: token);

  Future<dynamic> addCartItem({
    required String token,
    required int productId,
    int quantity = 1,
    int? variationId,
    Map<String, String> variation = const <String, String>{},
  }) {
    final body = <String, dynamic>{
      'product_id': productId,
      'id': productId,
      'quantity': quantity,
      if (variationId != null && variationId > 0) 'variation_id': variationId,
      if (variation.isNotEmpty) 'variation': variation,
    };
    return _authorizedJsonRequest(method: 'POST', url: _urlCart, token: token, body: body);
  }

  Future<dynamic> updateCartItem({
    required String token,
    required int productId,
    required int quantity,
    String? cartItemKey,
    Map<String, String> variation = const <String, String>{},
  }) {
    final body = <String, dynamic>{
      'product_id': productId,
      'id': productId,
      'quantity': quantity,
      if (cartItemKey != null && cartItemKey.trim().isNotEmpty) ...<String, dynamic>{'key': cartItemKey.trim(), 'cart_item_key': cartItemKey.trim()},
      if (variation.isNotEmpty) 'variation': variation,
    };
    return _authorizedJsonRequest(method: 'PUT', url: _urlCart, token: token, body: body);
  }

  Future<dynamic> deleteCartItem({
    required String token,
    required int productId,
    String? cartItemKey,
    Map<String, String> variation = const <String, String>{},
  }) {
    final body = <String, dynamic>{
      'product_id': productId,
      'id': productId,
      if (cartItemKey != null && cartItemKey.trim().isNotEmpty) ...<String, dynamic>{'key': cartItemKey.trim(), 'cart_item_key': cartItemKey.trim()},
      if (variation.isNotEmpty) 'variation': variation,
    };
    return _authorizedJsonRequest(method: 'DELETE', url: _urlCart, token: token, body: body);
  }

  Future<dynamic> getFavorites({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlFavorites, token: token);

  Future<dynamic> getViewedProducts({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlViewedProducts, token: token);

  Future<dynamic> getCustomerComments({required String token}) => _authorizedJsonRequest(method: 'GET', url: _urlComments, token: token);

  Future<dynamic> signUp({required BuildContext context, required String email, required String password}) => register(identifier: email, password: password);

  Future<dynamic> signIn({required BuildContext context, required String email, required String password}) => login(identifier: email, password: password);
}
