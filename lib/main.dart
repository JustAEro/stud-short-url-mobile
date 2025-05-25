import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stud_short_url_mobile/pages/reports_page.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';

import 'pages/create_short_link_page.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';
import 'services/navigation_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: "env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = AuthService().isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthenticated,
      builder: (context, snapshot) {
        // Пока не получены данные — просто спиннер
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Выбор домашней страницы
        final bool isAuthenticated = snapshot.data ?? false;
        final Widget homePage =
            isAuthenticated ? const MainPage() : const LoginPage();

        // Только один MaterialApp
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Short Links',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: homePage,
          routes: {
            '/create': (context) => const CreateShortLinkPage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const RegisterPage(),
            '/reports': (context) => const ReportsPage(),
          },
          
          locale: ui.PlatformDispatcher.instance.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
