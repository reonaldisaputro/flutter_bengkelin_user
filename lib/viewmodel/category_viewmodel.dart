import 'package:flutter/foundation.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class CategoryViewmodel {
  Future<Resp> getCategories() async {
    try {
      debugPrint('Fetching categories from: ${Endpoint.categoryUrl}');
      var resp = await Network.getApi(Endpoint.categoryUrl);
      debugPrint('Categories response: $resp');

      if (resp == null) {
        return Resp(code: 500, message: 'No response from server');
      }

      Resp data = Resp.fromJson(resp);
      return data;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return Resp(code: 500, message: 'Error: $e');
    }
  }
}
