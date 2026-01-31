import 'dart:io';

import 'package:flutter/material.dart';

import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';
import '../config/pref.dart';
import '../model/forgot_password_model.dart';

class AuthViewmodel {
  Future<Resp> login({email, password}) async {
    Map<String, dynamic> formData = {"email": email, "password": password};
    debugPrint("ini formdata $formData");
    debugPrint("ini url ${Endpoint.authLoginUrl}");

    var resp = await Network.postApi(Endpoint.authLoginUrl, formData);
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> register({
    name,
    email,
    phone,
    password,
    confirmPassword,
    kecamatanId,
    kelurahanId,
  }) async {
    Map<String, dynamic> formData = {
      "name": name,
      "email": email,
      "phone_number": phone,
      "alamat": "Jl. Contoh",
      "kecamatan_id": int.parse(kecamatanId.toString()),
      "kelurahan_id": int.parse(kelurahanId.toString()),
      "password": password,
      "password_confirmation": password,
    };
    debugPrint("form $formData");

    var resp = await Network.postApi(Endpoint.authRegisterUrl, formData);
    if (resp is Map<String, dynamic>) {
      return Resp.fromJson(resp);
    } else {
      throw Exception(
        "Invalid response format: expected Map but got ${resp.runtimeType}",
      );
    }
  }

  Future<Resp> logout() async {
    String? token = await Session().getUserToken();

    var header = <String, dynamic>{};
    header[HttpHeaders.authorizationHeader] = 'Bearer $token';

    var resp = await Network.postApiWithHeadersWithoutData(
      Endpoint.logoutUrl,
      header,
    );
    Resp data = Resp.fromJson(resp);
    return data;
  }

  // Forgot Password Methods
  Future<Resp> sendOtp(String email) async {
    SendOtpRequest request = SendOtpRequest(email: email);

    debugPrint("Send OTP request: ${request.toJson()}");
    debugPrint("Send OTP URL: ${Endpoint.sendOtpUrl}");

    var resp = await Network.postApi(Endpoint.sendOtpUrl, request.toJson());
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> verifyOtp(String email, String otp) async {
    VerifyOtpRequest request = VerifyOtpRequest(email: email, otp: otp);

    debugPrint("Verify OTP request: ${request.toJson()}");
    debugPrint("Verify OTP URL: ${Endpoint.verifyOtpUrl}");

    var resp = await Network.postApi(Endpoint.verifyOtpUrl, request.toJson());
    var data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    ResetPasswordRequest request = ResetPasswordRequest(
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    debugPrint("Reset password request: ${request.toJson()}");
    debugPrint("Reset password URL: ${Endpoint.resetPasswordUrl}");

    var resp = await Network.postApi(
      Endpoint.resetPasswordUrl,
      request.toJson(),
    );
    var data = Resp.fromJson(resp);
    return data;
  }
}
