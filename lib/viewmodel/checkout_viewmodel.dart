
import 'dart:io';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class CheckoutViewmodel {

  Future<Resp> getCheckoutSummary() async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';

    var resp = await Network.getApiWithHeaders(Endpoint.checkoutSummary, header);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> checkout({ongkir,administrasi, grandTotal}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';


    Map<String, dynamic> formData = {
      "ongkir": ongkir,
      "administrasi": administrasi,
      "grand_total": grandTotal
    };

    var resp = await Network.postApiWithHeaders(Endpoint.checkoutUrl, formData, header);
    var data = Resp.fromJson(resp);
    return data;
  }
}