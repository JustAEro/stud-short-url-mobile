import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';

import 'pages/create_short_link_page.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Short Links',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator())); // Пока загружается
          } else if (snapshot.hasData && snapshot.data == true) {
            return MainPage(); // Если авторизован
          } else {
            return LoginPage(); // Если не авторизован
          }
        },
      ),
      // initialRoute: '/',
      routes: {
        // '/': (context) => MainPage(),
        '/create': (context) => CreateShortLinkPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => RegisterPage(),
      },
    );
  }
}