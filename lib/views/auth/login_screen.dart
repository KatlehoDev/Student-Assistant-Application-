import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../student/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authVM = Provider.of<AuthViewModel>(
      context,
      listen: false,
    );

    final success = await authVM.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final email = emailController.text.trim();

      if (email == 'admin@gmail.com') {
        Navigator.pushNamed(context, '/admin');
      } else {
        Navigator.pushNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(
            authVM.errorMessage ?? 'Login failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // STARLIGHT ICON
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.blueGrey.shade100,

                      child: Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: Colors.amber.shade700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TITLE
                    Text(
                      "Startlight Application Portal",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Login to continue",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // EMAIL FIELD
                    TextFormField(
                      controller: emailController,

                      decoration: InputDecoration(
                        labelText: 'Email',

                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.blueGrey.shade700,
                        ),

                        filled: true,
                        fillColor: Colors.blueGrey.shade50,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.blueGrey,
                            width: 2,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD FIELD
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,

                      decoration: InputDecoration(
                        labelText: 'Password',

                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.blueGrey.shade700,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blueGrey,
                          ),

                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),

                        filled: true,
                        fillColor: Colors.blueGrey.shade50,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.blueGrey,
                            width: 2,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ERROR MESSAGE
                    if (authVM.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),

                        child: Text(
                          authVM.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          elevation: 3,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onPressed: authVM.isLoading
                            ? null
                            : handleLogin,

                        child: authVM.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // REGISTER BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },

                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}