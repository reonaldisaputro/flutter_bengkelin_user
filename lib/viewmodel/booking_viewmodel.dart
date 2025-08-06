
import 'dart:io';

import 'package:flutter/material.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class BookingViewmodel {

  Future<Resp> bookingBengkel({bengkelId, bookingDate, timeBooking, brand, model, plat, tahunPembuatan, kilometer, transmisi, notes}) async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';
    debugPrint("headers $header");


    Map<String, dynamic> formData = {
      "bengkel_id": bengkelId,
      "tanggal_booking": bookingDate,
      "waktu_booking": timeBooking,
//   "layanan_ids": [1],
      "brand": brand,
      "model": model,
      "plat": plat,
      "tahun_pembuatan": tahunPembuatan,
      "kilometer": kilometer,
      "transmisi": transmisi,
      "catatan_tambahan": notes ?? ""
    };

    debugPrint("testtt $formData");

    var resp = await Network.postApiWithHeaders(Endpoint.bookingUrl, formData, header);
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> userBooking() async {

    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';
    if (token == null) {
      return Resp(statusCode: 401, data: null, error: "Token is null");
    }

    var resp =
    await Network.getApiWithHeaders(Endpoint.userBookingUrl, header);
    Resp data = Resp.fromJson(resp);
    return data;
  }
}