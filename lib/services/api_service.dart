import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.200.166:3000/user/';
  //static const String baseUrl = 'http://78.38.35.193:3000/user/';

  static Future<Map<String, dynamic>> login(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl + endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': 200,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
        };
      }
    } on TimeoutException {
      return {'success': false, 'statusCode': 408, 'error': 'timeout'};
    } on SocketException {
      return {'success': false, 'statusCode': 503, 'error': 'network_error'};
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //print('request start');
    //print(token);
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl + endpoint),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
      //print(response.statusCode);
      //print(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': 200,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
        };
      }
    } on TimeoutException {
      return {'success': false, 'statusCode': 408, 'error': 'timeout'};
    } on SocketException {
      return {'success': false, 'statusCode': 503, 'error': 'network_error'};
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl + endpoint),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statusCode': 200,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
        };
      }
    } on TimeoutException {
      return {'success': false, 'statusCode': 408, 'error': 'timeout'};
    } on SocketException {
      return {'success': false, 'statusCode': 503, 'error': 'network_error'};
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'error': 'unknown_error',
        'message': e.toString(),
      };
    }

    // if (response.statusCode == 200) {
    //   return json.decode(response.body);
    // } else {
    //   return {
    //     'success': false,
    //     'error': 'HTTP ${response.statusCode}',
    //   };
    // }
  }
}
