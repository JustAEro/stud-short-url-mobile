import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stud_short_url_mobile/services/auth_service.dart';

import 'edit_page.dart';
import 'permissions_page.dart';
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

  final AuthService _authService = AuthService();

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
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/short-links/no-stats/${widget.shortKey}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          shortLinkData = json.decode(response.body);
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

    final bool isOwner = shortLinkData?['isOwner'] ?? false;

    return Scaffold(
      // appBar: AppBar(title: const Text("Short Link")),
      body:
          [
            StatisticsPage(linkId: widget.linkId, shortKey: widget.shortKey),
            EditPage(linkId: widget.linkId, shortKey: widget.shortKey),
            if (isOwner)
              PermissionsPage(linkId: widget.linkId, isOwner: isOwner),
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
          NavigationDestination(
            icon: Icon(Icons.edit),
            label: "Редактирование",
          ),
          if (isOwner)
            NavigationDestination(icon: Icon(Icons.lock), label: "Доступ"),
        ],
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
