import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/auth_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/forgot_password_verify_otp_page.dart';

import '../widget/custom_toast.dart';

class ForgotPasswordSendOtpPage extends StatefulWidget {
  const ForgotPasswordSendOtpPage({super.key});

  @override
  State<ForgotPasswordSendOtpPage> createState() =>
      _ForgotPasswordSendOtpPageState();
}

class _ForgotPasswordSendOtpPageState extends State<ForgotPasswordSendOtpPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  RegExp get emailRegex => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final authViewModel = AuthViewmodel();
      final response = await authViewModel.sendOtp(
        _emailController.text.trim(),
      );

      if (response.code == 200) {
        showToast(
          context: context,
          msg: response.message,
          colors: const Color(0xFF4A6B6B),
        );

        // Navigate to verify OTP page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordVerifyOtpPage(
              email: _emailController.text.trim(),
            ),
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
                'Lupa Kata Sandi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Masukkan alamat email Anda untuk mendapatkan kode OTP reset kata sandi.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Email Input Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Alamat Email',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendOtp,
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
                          'Kirim Kode OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kembali ke Halaman Login',
                    style: TextStyle(
                      color: const Color(0xFF4A6B6B),
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
