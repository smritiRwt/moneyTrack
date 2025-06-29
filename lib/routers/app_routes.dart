import 'package:expense/views/home.dart';
import 'package:expense/views/login_screen.dart';
import 'package:expense/views/signup_screen.dart' show SignupScreen;
import 'package:expense/views/tabbar.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const TabbarPage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
