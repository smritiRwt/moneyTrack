import 'package:expense/core/constants/constants.dart';
import 'package:expense/views/components/auth_button.dart';
import 'package:expense/views/components/custom_text_field.dart';
import 'package:expense/views/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/providers/auth_provider.dart';
import 'package:expense/core/constants/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final isLoading = ref.watch(loginLoadingProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                // Text(
                //   "Welcome Back",
                //   textAlign: TextAlign.center,
                //   style: theme.textTheme.bodyLarge?.copyWith(
                //     color: isDarkMode ? Colors.white : Colors.black87,
                //     fontWeight: FontWeight.normal,
                //     fontSize: 22,
                //   ),
                // ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:  Colors.black54,
                    fontWeight: FontWeight.normal,
                    fontSize: 22
                  ),
                ),
                const SizedBox(height: 40),
                Image.asset(Constants.logoimage, height: 150),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                AuthButton(
                  label: isLoading ? "Signing in..." : "Login",
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              ref.read(loginLoadingProvider.notifier).state =
                                  true;
                              try {
                                final user = await ref
                                    .read(authServiceProvider)
                                    .login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );

                                if (context.mounted && user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Login successful!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TabbarPage(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ Login failed: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  ref
                                      .read(loginLoadingProvider.notifier)
                                      .state = false;
                                }
                              }
                            }
                          },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color:
                              Constants.lavender,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
