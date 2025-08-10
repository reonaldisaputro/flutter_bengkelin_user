

import 'dart:io';
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class RatingViewmodel {

  Future<Resp> getRatingProduct({
    required int productId,
    int page = 1,
    int perPage = 10, // opsional, backend kamu default 10
  }) async {
    final String? token = await Session().getUserToken();
    if (token == null) {
      return Resp(statusCode: 401, data: null, error: "Token is null");
    }

    final headers = <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    // Bangun URL dengan query page & per_page yang rapi
    final uri = Uri.parse("${Endpoint.ratingUrl}/product/$productId")
        .replace(queryParameters: {
      'page': page < 1 ? '1' : page.toString(),
      'per_page': perPage.toString(), // boleh dihapus kalau tidak dipakai
    });

    final resp = await Network.getApiWithHeaders(uri.toString(), headers);
    return Resp.fromJson(resp);
  }

  Future<Resp> ratingProduct({detailTransactionId, stars, comment}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';


    Map<String, dynamic> formData = {
      "detail_transaction_id": detailTransactionId,
      "stars": stars,
      "comment": comment,
    };

    var resp = await Network.postApiWithHeaders(Endpoint.ratingUrl, formData, header);
    var data = Resp.fromJson(resp);
    return data;
  }
}