class SendOtpRequest {
  final String email;

  SendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class SendOtpResponse {
  final String email;

  SendOtpResponse({required this.email});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(email: json['email']);
  }
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class VerifyOtpResponse {
  final String email;
  final bool verified;

  VerifyOtpResponse({required this.email, required this.verified});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(email: json['email'], verified: json['verified']);
  }
}

class ResetPasswordRequest {
  final String email;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequest({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
