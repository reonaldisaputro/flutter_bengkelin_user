// lib/viewmodel/service_viewmodel.dart

import 'package:flutter/foundation.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class ServiceViewmodel extends ChangeNotifier {
  Future<Resp> kecamatan() async {
    final response = await Network.getApi(Endpoint.kecamatanUrl);
    return Resp.fromJson(response); // ⬅️ Ini benar
  }

  Future<Resp> kelurahan({required int kecamatanId}) async {
    final String url = '${Endpoint.kelurahanUrl}/$kecamatanId';
    final response = await Network.getApi(url);
    return Resp.fromJson(response);
  }

  
}
