import 'package:flutter/material.dart';

import 'statistics_page.dart';

class ShortLinkPage extends StatefulWidget {
  final String linkId;

  const ShortLinkPage({super.key, required this.linkId});

  @override
  State<ShortLinkPage> createState() => _ShortLinkPageState();
}

class _ShortLinkPageState extends State<ShortLinkPage> {
  Map<String, dynamic>? shortLinkData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadShortLinkData();
  }

  void _loadShortLinkData() {
    setState(() {
      shortLinkData = {
        "id": widget.linkId,
        "longLink": "https://example.com",
        "shortKey": "exmpl",
        "createdByUserId": "user123",
        "createdAt": DateTime.now().subtract(const Duration(days: 10)),
        "updatedAt": DateTime.now(),
        "description": "Example description",
        "isOwner": true,
        "canEdit": true,
        "user": {
          "login": "user123",
          "id": "user123",
          "accessToken": "mock_token",
        },
      };
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Short Link")),
      body: [
        StatisticsPage(linkId: widget.linkId),
        EditPage(linkId: widget.linkId),
        PermissionsPage(linkId: widget.linkId)
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(110, 33, 149, 243),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: "Статистика",
          ),
          NavigationDestination(
            icon: Icon(Icons.edit),
            label: "Редактирование",
          ),
          NavigationDestination(icon: Icon(Icons.lock), label: "Права"),
        ],
        selectedIndex: _selectedIndex,
      ),
    );
  }
}

class EditPage extends StatelessWidget {
  final String linkId;
  const EditPage({super.key, required this.linkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактирование")),
      body: Center(child: Text("Редактирование $linkId")),
    );
  }
}

class PermissionsPage extends StatelessWidget {
  final String linkId;
  const PermissionsPage({super.key, required this.linkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Права доступа")),
      body: Center(child: Text("Права для $linkId")),
    );
  }
}
