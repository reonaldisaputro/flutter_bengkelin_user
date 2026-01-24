import 'package:flutter/foundation.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class SpecialistViewmodel {
  Future<Resp> getSpecialists() async {
    try {
      var resp = await Network.getApi(Endpoint.specialistUrl);

      if (resp == null) {
        return Resp(code: 500, message: 'No response from server');
      }

      Resp data = Resp.fromJson(resp);
      return data;
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
      return Resp(code: 500, message: 'Error: $e');
    }
  }
}
