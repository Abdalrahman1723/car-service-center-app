import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';
import 'package:m_world/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  String? _errorResetMessage;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool emailSent = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        // if (_emailController.text.trim() == "mohamed@gmail.com") {
        //   Navigator.pushReplacementNamed(context, Routes.adminDashboard);
        // }

        final user = authService.currentUser;
        if (user != null) {
          final role = await authService.getUserRole(user.uid);
          log("the login user id ${user.uid} and the role $role ");
          if (role != null) {
            switch (role) {
              case UserRole.admin:
                Navigator.pushReplacementNamed(context, Routes.adminDashboard);
                break;
              case UserRole.supervisor:
                Navigator.pushReplacementNamed(
                  context,
                  Routes.supervisorDashboard,
                );
                break;
              case UserRole.inventory:
                Navigator.pushReplacementNamed(
                  context,
                  Routes.inventoryDashboard,
                );
                break;
            }
          } else {
            setState(() {
              _errorMessage = 'لم يتم العثور على دور المستخدم';
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      default:
        return 'حدث خطأ. حاول مرة أخرى';
    }
  }

  //forgot password
  Future<void> sendResetEmail() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: "mw3837161@gmail.com", //!change later
      );
      setState(() {
        emailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorResetMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorResetMessage = "حدث خطأ ما.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('تسجيل الدخول'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحبًا بك في ${AppStrings.appName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            //----enter email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: AppStrings.email,
                hintText: 'أدخل البريد الإلكتروني',
              ),
              textDirection: TextDirection.ltr, // Email input in LTR
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            //----enter password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppStrings.password,
                hintText: 'أدخل كلمة المرور',
                suffixIcon: _isPasswordVisible
                    ? IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        onPressed: _togglePasswordVisibility,
                      )
                    : IconButton(
                        icon: const Icon(Icons.visibility_off),
                        onPressed: _togglePasswordVisibility,
                      ),
              ),
              textDirection: TextDirection.ltr, // Password input in LTR
              obscureText: _isPasswordVisible ? false : true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            //forgot password
            TextButton(
              onPressed: sendResetEmail,
              child: const Text("هل نسيت كلمة المرور؟"),
            ),
            const SizedBox(height: 20),
            if (emailSent)
              const Text(
                "تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين!",
                style: TextStyle(color: Colors.green),
              ),
            if (_errorResetMessage != null)
              Text(
                _errorResetMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            //----login button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('تسجيل الدخول'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
