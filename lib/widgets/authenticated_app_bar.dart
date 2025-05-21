import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:stud_short_url_mobile/pages/login_page.dart';

class AuthenticatedAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;

  final bool showReportsButton;

  const AuthenticatedAppBar({
    super.key,
    required this.title,
    this.showReportsButton = false,
  });

  @override
  State<AuthenticatedAppBar> createState() => _AuthenticatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AuthenticatedAppBarState extends State<AuthenticatedAppBar> {
  String? userLogin;

  @override
  void initState() {
    super.initState();
    _loadUserLogin();
  }

  Future<void> _loadUserLogin() async {
    final userInfo = await AuthService().getUserInfo();
    setState(() {
      userLogin = userInfo!['login'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          widget.showReportsButton
              ? IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Отчеты',
                onPressed: () {
                  Navigator.pushNamed(context, '/reports');
                },
              )
              : null,
      centerTitle: true,
      title: Text(widget.title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 0.0),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            offset: const Offset(0, kToolbarHeight),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: SelectableText(
                      userLogin ?? '...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text(
                      'Выйти',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
          ),
        ),
      ],
    );
  }
}
