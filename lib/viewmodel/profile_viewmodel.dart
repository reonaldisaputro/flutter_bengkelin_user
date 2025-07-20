
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
}