

import 'dart:io';

import 'package:flutter/material.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';

class ChatViewmodel {
  Future<Resp> send({
    String? message,
    String? payload,
    String? contextId,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final String? token = await Session().getUserToken();
    if (token == null) {
      return Resp(statusCode: 401, data: null, error: "Token is null");
    }

    final headers = <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };

    final body = <String, dynamic>{
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      if (payload != null && payload.trim().isNotEmpty) 'payload': payload.trim(),
      if (contextId != null && contextId.trim().isNotEmpty) 'context_id': contextId.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
    };

    debugPrint("token $token");
    debugPrint("body nya chat send $body");

    final resp = await Network.postApiWithHeaders(Endpoint.chatUrl, body, headers);

    // Debug: Check response type
    debugPrint("Response type: ${resp.runtimeType}");
    debugPrint("Response content: $resp");

    return Resp.fromJson(resp);
  }
}