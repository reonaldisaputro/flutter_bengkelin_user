// lib/viewmodel/service_viewmodel.dart

import 'package:flutter/foundation.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class ServiceViewmodel extends ChangeNotifier {
  Future<Resp> kecamatan() async {
    debugPrint(
      'ServiceViewmodel - Fetching kecamatan from: ${Endpoint.kecamatanUrl}',
    );
    return await Network.getApi(Endpoint.kecamatanUrl);
  }

  Future<Resp> kelurahan({required int kecamatanId}) async {
    // Sesuaikan URL jika API kelurahan Anda menggunakan query parameter seperti ?kecamatan_id=123
    // Contoh: final String url = '${Endpoint.kelurahanUrl}?kecamatan_id=$kecamatanId';
    // Atau jika API Anda menggunakan path parameter seperti /api/service/kelurahan/123
    final String url = '${Endpoint.kelurahanUrl}/$kecamatanId';
    debugPrint('ServiceViewmodel - Fetching kelurahan from: $url');
    return await Network.getApi(url);
  }

  Future<Resp> registerUser({
    required String fullName,
    required String username,
    required String email,
    required int kecamatanId,
    required int kelurahanId,
    required String password,
  }) async {
    final String url = Endpoint.authRegisterUrl; // Menggunakan authRegisterUrl
    debugPrint('ServiceViewmodel - Registering user to: $url');

    final Map<String, dynamic> body = {
      'nama_lengkap': fullName,
      'username': username,
      'email': email,
      'kecamatan_id': kecamatanId,
      'kelurahan_id': kelurahanId,
      'password': password,
      // Jika backend Anda mengharapkan 'password_confirmation' juga, tambahkan:
      // 'password_confirmation': password,
    };

    return await Network.postApi(url, body);
  }
}
