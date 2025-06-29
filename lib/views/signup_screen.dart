import 'package:expense/core/constants/constants.dart';
import 'package:expense/views/components/auth_button.dart';
import 'package:expense/views/components/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/providers/auth_provider.dart';
import 'package:expense/core/constants/app_theme.dart';

final signupLoadingProvider = StateProvider<bool>((ref) => false);

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final isLoading = ref.watch(signupLoadingProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Constants.whiteColor,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                   
                    Text(
                      "Sign up to get started",
                      textAlign: TextAlign.center,
                       style: theme.textTheme.displaySmall?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Image.asset(Constants.logoimage, height: 150),
                    const SizedBox(height: 60),
                    CustomTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      enabled: !isLoading,
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
                      enabled: !isLoading,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 60),
                    AuthButton(
                      label: isLoading ? "Creating Account..." : "Sign Up",
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (formKey.currentState!.validate()) {
                                  ref
                                      .read(signupLoadingProvider.notifier)
                                      .state = true;
                                  try {
                                    final user = await ref
                                        .read(authServiceProvider)
                                        .signUp(
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );

                                    if (!context.mounted) return;

                                    if (user != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '🎉 Account created successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '⚠️ Error: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      ref
                                          .read(signupLoadingProvider.notifier)
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
                          "Already have an account? ",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Login",
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
        ),
      
      ],
    );
  }
}
