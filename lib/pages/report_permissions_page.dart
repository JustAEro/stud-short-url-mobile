import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

class ReportPermissionsPage extends StatefulWidget {
  final String reportId;
  final bool canManagePermissions;

  const ReportPermissionsPage({
    super.key,
    required this.reportId,
    required this.canManagePermissions,
  });

  @override
  State<ReportPermissionsPage> createState() => _ReportPermissionsPageState();
}

class _ReportPermissionsPageState extends State<ReportPermissionsPage> {
  final _dio = DioClient().dio;
  final TextEditingController _loginController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> roles = ['viewer', 'editor', 'admin'];
  final Map<String, String> roleLabels = {
    'viewer': 'Просмотр',
    'editor': 'Редактирование',
    'admin': 'Администрирование',
  };

  List<Map<String, String>> users = [];
  String selectedRole = 'viewer';
  bool _isLoading = true;

  Icon getRoleIcon(String role) {
    switch (role) {
      case 'viewer':
        return const Icon(Icons.remove_red_eye, color: Colors.blue);
      case 'editor':
        return const Icon(Icons.edit, color: Colors.orange);
      case 'admin':
        return const Icon(Icons.security, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(
        '/api/v1/report-permission/${widget.reportId}',
      );
      final data = response.data as List;

      setState(() {
        users =
            data
                .map(
                  (user) => {
                    'login': user['login'].toString(),
                    'role': user['role'].toString(),
                  },
                )
                .toList();
      });
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки прав доступа')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPermission(String login, String role) async {
    if (login.isEmpty) return;

    try {
      final response = await _dio.post(
        '/api/v1/report-permission/add/${widget.reportId}',
        data: {'login': login, 'role': role},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _loginController.clear();
        setState(() => selectedRole = 'viewer');
        _loadPermissions();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка добавления пользователя: ${response.data}'),
          ),
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
      final response = await _dio.delete(
        '/api/v1/report-permission/remove/${widget.reportId}/login/$login',
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

  Future<void> _updatePermission(String login, String newRole) async {
    try {
      final response = await _dio.patch(
        '/api/v1/report-permission/update/${widget.reportId}',
        data: {'login': login, 'role': newRole},
      );

      if (response.statusCode == 200) {
        _loadPermissions();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка обновления роли')));
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
      appBar: const AuthenticatedAppBar(title: "Права доступа"),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Пользователи с правами доступа',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          controller: _scrollController,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              title: Text(user['login']!),
                              trailing: SizedBox(
                                width: 130,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    DropdownButton<String>(
                                      value: user['role'],
                                      items:
                                          roles.map((role) {
                                            return DropdownMenuItem<String>(
                                              value: role,
                                              child: Row(
                                                children: [getRoleIcon(role)],
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          _updatePermission(
                                            user['login']!,
                                            value,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () =>
                                              _removePermission(user['login']!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (widget.canManagePermissions)
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _loginController,
                                          decoration: const InputDecoration(
                                            labelText: 'Логин пользователя',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: selectedRole,
                                          decoration: const InputDecoration(
                                            labelText: 'Роль',
                                            border: OutlineInputBorder(),
                                          ),
                                          items:
                                              roles.map((role) {
                                                return DropdownMenuItem<String>(
                                                  value: role,
                                                  child: Row(
                                                    children: [
                                                      getRoleIcon(role),
                                                      const SizedBox(width: 8),
                                                      Text(roleLabels[role]!),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedRole = value;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            _addPermission(
                                              _loginController.text,
                                              selectedRole,
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Добавить',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Добавить пользователя',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
