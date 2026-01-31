import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bengkelin_user/viewmodel/auth_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/forgot_password_reset_password_page.dart';

import '../widget/custom_toast.dart';

class ForgotPasswordVerifyOtpPage extends StatefulWidget {
  final String email;

  const ForgotPasswordVerifyOtpPage({super.key, required this.email});

  @override
  State<ForgotPasswordVerifyOtpPage> createState() =>
      _ForgotPasswordVerifyOtpPageState();
}

class _ForgotPasswordVerifyOtpPageState
    extends State<ForgotPasswordVerifyOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool canResend = false;
  int countdown = 600; // 10 minutes in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formatTime {
    int minutes = countdown ~/ 60;
    int seconds = countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      showToast(
        context: context,
        msg: 'Silakan masukkan kode OTP lengkap',
        colors: Colors.red,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authViewModel = AuthViewmodel();
      final response = await authViewModel.verifyOtp(widget.email, otpCode);

      if (response.code == 200 || response.code == 201) {
        showToast(
          context: context,
          msg: response.message,
          colors: const Color(0xFF4A6B6B),
        );

        // Navigate to reset password page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ForgotPasswordResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        showToast(context: context, msg: response.message, colors: Colors.red);
      }
    } catch (e) {
      showToast(
        context: context,
        msg: 'Terjadi kesalahan. Silakan coba lagi.',
        colors: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authViewModel = AuthViewmodel();
      final response = await authViewModel.sendOtp(widget.email);

      if (response.success) {
        showToast(
          context: context,
          msg: 'Kode OTP baru telah dikirim',
          colors: const Color(0xFF4A6B6B),
        );

        // Reset countdown
        setState(() {
          countdown = 600;
          canResend = false;
        });
        _startCountdown();

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        showToast(context: context, msg: response.message, colors: Colors.red);
      }
    } catch (e) {
      showToast(
        context: context,
        msg: 'Terjadi kesalahan. Silakan coba lagi.',
        colors: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2A3B)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verifikasi OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Masukkan kode OTP 6 digit yang telah dikirim ke email ${widget.email}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Timer
              Center(
                child: Text(
                  canResend
                      ? 'Kode OTP telah kedaluwarsa'
                      : 'Kode berlaku selama $_formatTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: canResend ? Colors.red : Colors.grey[600],
                    fontWeight: canResend ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6B6B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          'Verifikasi OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: canResend && !isLoading ? _resendOtp : null,
                  child: Text(
                    'Kirim Ulang Kode OTP',
                    style: TextStyle(
                      color: canResend ? const Color(0xFF4A6B6B) : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
