
import 'dart:io';
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class ProfileViewmodel {

  Future<Resp> getUserProfile() async {

    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';
    if (token == null) {
      return Resp(statusCode: 401, data: null, error: "Token is null");
    }

    var resp =
    await Network.getApiWithHeaders(Endpoint.userProfileUrl, header);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String alamat,
    int? kecamatanId,
    int? kelurahanId,
  }) async {
    String? token = await Session().getUserToken();
    if (token == null) {
      return Resp(statusCode: 401, data: null, error: "Token is null");
    }

    var header = <String, dynamic>{
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'alamat': alamat,
    };

    if (kecamatanId != null) body['kecamatan_id'] = kecamatanId;
    if (kelurahanId != null) body['kelurahan_id'] = kelurahanId;

    var resp = await Network.putApiWithHeaders(
      Endpoint.updateProfileUrl,
      body,
      header,
    );
    return Resp.fromJson(resp);
  }
}