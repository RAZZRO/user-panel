import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_panel/services/api_service.dart';
//import 'dart:convert';
import 'package:user_panel/models/device.dart';

final deviceProvider = FutureProvider<List<Device>>((ref) async {
  const url = 'all_topics';
  print('device provider');

  final result = await ApiService.getRequest(
    url,
  );
  //print(object)

  if (result['success'] == true) {
    print(result);
    final List<dynamic> listData = result['data'];
    print(listData);

    return listData
        .map<Device>((device) => Device(
              name: device["device_name"],
              identifier: device['identifier'].toString(),
              registerDate: device['start_date'].toString(),
            ))
        .toList();
  } else {
    throw Exception('unable to fetch devices');
  }
});


// final deviceProvider =
//     FutureProvider.family<List<Device>, String>((ref, nationalCode) async {
//   const url = 'http://10.0.2.2:3000/admin/all_topics';

//   try {
//     final result = await ApiService.postRequest(
//       url,
//       {
//         "nationalCode": nationalCode,
//       },
//     );

//     if (result['success'] == true) {
//       final List<dynamic> listData = json.decode(result["data"]);

//       return listData
//           .map<Device>((device) => Device(
//                 name: device["device_name"],
//                 identifier: device['username'],
//                 registerDate: device['start_date'],
//               ))
//           .toList();
//     } else {
//       throw Exception('unable to fetch devices');
//     }
//   } catch (error) {
//     throw Exception('unable to fetch users: $error');
//   }
// });



