
import 'dart:io';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class CartViewmodel {

  Future<Resp> carts() async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';

    var resp = await Network.getApiWithHeaders(Endpoint.cartUrl, header);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> removeCart({id}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';

    var resp = await Network.deleteApiWithHeaders("${Endpoint.cartUrl}/$id", header);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> updateQuantity({id,qty}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';


    Map<String, dynamic> formData = {
      "quantity": qty,
    };

    var resp = await Network.putApiWithHeaders("${Endpoint.cartUrl}/$id", formData, header);
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> addCart({productId, bengkelId}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';


    Map<String, dynamic> formData = {
      "product_id": productId,
      "quantity": 1,
      "bengkel_id": bengkelId
    };

    var resp = await Network.postApiWithHeaders("${Endpoint.cartUrl}/add", formData, header);
    var data = Resp.fromJson(resp);
    return data;
  }
}