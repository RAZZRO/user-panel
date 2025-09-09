// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:admin_panel/services/api_service.dart';
// import 'dart:convert';
// import 'package:admin_panel/models/user_model.dart';

// final usersProvider = FutureProvider<List<User>>((ref) async {
//   const url = 'http://10.0.2.2:3000/admin/all_users';

//   try {
//     final result = await ApiService.getRequest(url);

//     if (result['success'] == true) {
//       final List<dynamic> listData = json.decode(result["data"]);

//       return listData
//           .map<User>((user) => User(
//                 nationalCode: user["id"],
//                 firstName: user['first_name'],
//                 lastName: user['last_name'],
//                 phone: user['phone'],
//                 startDate: user['start_date'],
//               ))
//           .toList();
//     } else {
//       throw Exception('unable to fetch users');
//     }
//   } catch (error) {
//     throw Exception('unable to fetch users: $error');
//   }
// });
