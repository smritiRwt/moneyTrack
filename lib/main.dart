import 'package:expense/core/constants/app_theme.dart';
import 'package:expense/providers/auth_provider.dart';
import 'package:expense/routers/app_routes.dart';
import 'package:expense/views/home.dart';
import 'package:expense/views/login_screen.dart';
import 'package:expense/views/signup_screen.dart';
import 'package:expense/views/tabbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Expensio',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: authState.when(
        data:
            (user) => user == null ? const SignupScreen() : const TabbarPage(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
