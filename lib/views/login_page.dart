import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/auth_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/home_page.dart';
import 'package:flutter_bengkelin_user/views/register_page.dart';
import 'package:flutter_bengkelin_user/views/forgot_password_send_otp_page.dart';

import '../../config/app_color.dart';
import '../../config/pref.dart';
import '../../widget/custom_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false, isLoading = false;
  final TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  RegExp get emailRegex => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light grey background
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100), // Spacing from top
              const Text(
                'Masuk Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3B), // Dark text color
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Masuk ke dalam akun untuk bisa maksimal dalam\nmenggunakan fitur aplikasi.',
                textAlign: TextAlign.center,
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
                    borderSide: BorderSide.none, // No border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Input Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Kata Sandi',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // No border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Masuk Sekarang Button
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                          strokeWidth: 2,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (isLoading == false &&
                              _formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF4A6B6B,
                          ), // Greenish button color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0, // No shadow
                        ),
                        child: const Text(
                          'Masuk sekarang',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 15),

              // Forgot Password Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordSendOtpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A6B6B),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum memiliki akun?',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to registration page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4A6B6B), // Greenish text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Implement 'Nanti Saja' logic, e.g., navigate to home without login
                },
                child: const Text(
                  'Nanti Saja',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  login() {
    AuthViewmodel()
        .login(email: _emailController.text, password: _passwordController.text)
        .then((value) async {
          if (value.code == 200) {
            setState(() {
              isLoading = false;
            });
            await Session().setUserToken(value.data["access_token"]);
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          } else {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            showToast(context: context, msg: value.message.toString());
          }
        });
  }
}
