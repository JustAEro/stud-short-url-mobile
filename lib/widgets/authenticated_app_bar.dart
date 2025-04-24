import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:stud_short_url_mobile/pages/login_page.dart';

class AuthenticatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AuthenticatedAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
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
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Выйти'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
