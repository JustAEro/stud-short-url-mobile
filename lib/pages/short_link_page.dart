import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/link-access-roles/link_access_roles.dart';

import 'edit_page.dart';
import 'permissions_page.dart';
import 'share_short_link_page.dart';
import 'statistics_page.dart';

class ShortLinkPage extends StatefulWidget {
  final String linkId;
  final String shortKey;

  const ShortLinkPage({
    super.key,
    required this.linkId,
    required this.shortKey,
  });

  @override
  State<ShortLinkPage> createState() => _ShortLinkPageState();
}

class _ShortLinkPageState extends State<ShortLinkPage> {
  Map<String, dynamic>? shortLinkData;
  int _selectedIndex = 0;
  bool _isLoading = true;

  final _dio = DioClient().dio;

  @override
  void initState() {
    super.initState();
    _loadShortLinkData();
  }

  Future<void> _loadShortLinkData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get(
        '/api/v1/short-links/no-stats/${widget.shortKey}',
      );

      if (response.statusCode == 200) {
        setState(() {
          shortLinkData = response.data;
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки данных ссылки')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения к серверу')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (shortLinkData == null) {
      return const Scaffold(
        body: Center(child: Text('Не удалось загрузить данные ссылки')),
      );
    }

    final AccessRole? role = parseRole(shortLinkData?['role']);
    final bool canEdit = role == AccessRole.editor || role == AccessRole.admin;
    final bool canManagePermissions = role == AccessRole.admin;

    return Scaffold(
      // appBar: AppBar(title: const Text("Short Link")),
      body:
          [
            StatisticsPage(linkId: widget.linkId, shortKey: widget.shortKey),
            EditPage(linkId: widget.linkId, shortKey: widget.shortKey),
            if (canManagePermissions)
              PermissionsPage(
                linkId: widget.linkId,
                canManagePermissions: canManagePermissions,
              ),
            ShareShortLinkPage(shortKey: widget.shortKey),
          ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(110, 33, 149, 243),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: "Статистика",
          ),
          if (canEdit)
            NavigationDestination(icon: Icon(Icons.edit), label: "Изменение")
          else
            NavigationDestination(icon: Icon(Icons.info), label: "Информация"),
          if (canManagePermissions)
            NavigationDestination(icon: Icon(Icons.lock), label: "Доступ"),
          NavigationDestination(icon: Icon(Icons.share), label: "Поделиться"),
        ],
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
