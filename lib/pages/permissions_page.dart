import 'package:flutter/material.dart';

class PermissionsPage extends StatefulWidget {
  final String linkId;
  const PermissionsPage({super.key, required this.linkId});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  List<Map<String, String>> users = [];
  final TextEditingController loginController = TextEditingController();

  void loadPermissions() {
    // Моковые данные пользователей с правами
    setState(() {
      users = [
        {'id': '1', 'login': 'user1'},
        {'id': '2', 'login': 'user2'},
      ];
    });
  }

  void addPermission(String login) {
    if (login.isEmpty) return;

    setState(() {
      users.add({'id': (users.length + 1).toString(), 'login': login});
    });
    loginController.clear();
  }

  void removePermission(String login) {
    setState(() {
      users.removeWhere((user) => user['login'] == login);
    });
  }

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Права доступа")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Пользователи с правами редактирования',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user['login']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => removePermission(user['login']!),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: loginController,
              decoration: const InputDecoration(
                labelText: 'Логин пользователя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => addPermission(loginController.text),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
