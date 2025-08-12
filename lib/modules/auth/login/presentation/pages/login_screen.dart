import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:m_world/config/routes.dart';
import 'package:m_world/core/constants/app_strings.dart';

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        _emailController.text.trim() == "mohamed@gmail.com"
            ? Navigator.pushNamed(context, Routes.adminDashboard)
            //todo: special screen for other users
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(
                      child: Text(
                        'Welcome Supervisor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
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
        email: "abdalrahman.alaa.eldin@gmail.com", //!change later
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
        _errorResetMessage = "Something went wrong.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('تسجيل الدخول'), // Login
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مرحبًا بك في ${AppStrings.appName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              //----enter email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني', // Email
                  hintText: 'Enter Email',
                ),
                textDirection: TextDirection.ltr, // Email input in LTR
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              //----enter password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور', // Password
                  hintText: 'Enter Password',
                  suffixIcon: _isPasswordVisible
                      ? IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: _togglePasswordVisibility,
                        )
                      : IconButton(
                          icon: Icon(Icons.visibility_off),
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
                child: Text("هل نسيت كلمة المرور؟"),
              ),
              const SizedBox(height: 20),
              if (emailSent)
                const Text(
                  "Check your email for the reset link!",
                  style: TextStyle(color: Colors.green),
                ),
              if (_errorMessage != null)
                Text(
                  "$_errorResetMessage",
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              //----login button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('تسجيل الدخول'), // Login
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
