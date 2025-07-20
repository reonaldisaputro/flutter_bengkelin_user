
import 'package:flutter/material.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class AuthViewmodel {
  Future<Resp> login({email, password}) async {

    Map<String, dynamic> formData = {
      "email": email,
      "password": password,
    };
    debugPrint("ini formdata $formData");
    debugPrint("ini url ${Endpoint.authLoginUrl}");

    var resp = await Network.postApi(Endpoint.authLoginUrl, formData);
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> register({name, email, phone, password, confirmPassword, kecamatanId, kelurahanId}) async {

    Map<String, dynamic> formData = {
      "name": name,
      "email": email,
      "phone_number": phone,
      "kecamatan_id": kecamatanId,
      "kelurahan_id": kelurahanId,
      "password": password,
      "password_confirmation": confirmPassword,
    };

    var resp = await Network.postApi(Endpoint.authRegisterUrl, formData);
    var data = Resp.fromJson(resp);
    return data;
  }
}