import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stud_short_url_mobile/services/auth_service.dart';

class PermissionsPage extends StatefulWidget {
  final String linkId;
  final bool isOwner;

  const PermissionsPage({
    super.key,
    required this.linkId,
    required this.isOwner,
  });

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  List<Map<String, String>> users = [];
  final TextEditingController loginController = TextEditingController();
  bool _isLoading = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    if (widget.isOwner) {
      _loadPermissions();
    }
  }

  Future<void> _loadPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/edit-permission/${widget.linkId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          users =
              data
                  .map(
                    (user) => {
                      'id': user['id'].toString(),
                      'login': user['login'].toString(),
                    },
                  )
                  .toList();
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки прав доступа')),
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

  Future<void> _addPermission(String login) async {
    if (login.isEmpty) return;

    try {
      final token = await _authService.getToken();

      final response = await http.post(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/edit-permission/add/${widget.linkId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'login': login}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _loadPermissions();
        loginController.clear();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка добавления пользователя: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения к серверу')),
      );
    }
  }

  Future<void> _removePermission(String login) async {
    try {
      final token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/edit-permission/remove/${widget.linkId}/login/$login',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _loadPermissions();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка удаления пользователя')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения к серверу')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Права доступа")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Пользователи с правами редактирования',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed:
                                  () => _removePermission(user['login']!),
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
                      onPressed: () => _addPermission(loginController.text),
                      child: const Text('Добавить'),
                    ),
                  ],
                ),
              ),
    );
  }
}
