import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:stud_short_url_mobile/link-access-roles/link_access_roles.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

class EditPage extends StatefulWidget {
  final String linkId;
  final String shortKey;

  const EditPage({super.key, required this.linkId, required this.shortKey});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  AccessRole? role;
  String creatorLogin = '';
  String createdAt = '';
  String updatedAt = '';
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();

    _fetchLinkDetails();
  }

  Future<void> _fetchLinkDetails() async {
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
        final data = json.decode(response.body);
        setState(() {
          _urlController.text = data['longLink'];
          _descriptionController.text = data['description'] ?? '';
          creatorLogin = data['user']['login'];
          createdAt = dateFormat.format(
            DateTime.parse(data['createdAt']).toLocal(),
          );
          updatedAt = dateFormat.format(
            DateTime.parse(data['updatedAt']).toLocal(),
          );
          role = parseRole(data['role']);
        });
      } else {
        if (!mounted) return;

        print('Error: ${response.body}');

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

  // Моковая функция обновления данных
  Future<void> _updateLink() async {
    final String updatedUrl = _urlController.text;
    final String updatedDescription = _descriptionController.text;

    try {
      final token = await _authService.getToken();

      final response = await http.put(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/short-links/${widget.shortKey}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'longLink': updatedUrl,
          'description': updatedDescription,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          updatedAt = dateFormat.format(
            DateTime.parse(data['updatedAt']).toLocal(),
          );
          _urlController.text = data['longLink'];
          _descriptionController.text = data['description'] ?? '';
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ссылка успешно обновлена')),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка обновления ссылки')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения к серверу')),
      );
    }
  }

  // Моковая функция удаления ссылки
  Future<void> _deleteLink() async {
    try {
      final token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/short-links/${widget.shortKey}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ссылка успешно удалена')));
        Navigator.pop(context);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка удаления ссылки')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения к серверу')),
      );
    }
  }

  bool get canEdit => role == AccessRole.editor || role == AccessRole.admin;
  bool get canDelete => role == AccessRole.admin;

  String get roleText => switch (role) {
    AccessRole.viewer => 'Просмотр',
    AccessRole.editor => 'Редактирование',
    AccessRole.admin => 'Администрирование',
    null => 'Неизвестно',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthenticatedAppBar(title: canEdit ? "Редактирование" : "Просмотр"),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("Редактирование короткой ссылки: ${widget.linkId}"),
                    const SizedBox(height: 16.0),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: const Color.fromARGB(211, 94, 179, 248),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  4, // Устанавливаем пропорции строк
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 8,
                            ),
                        children: [
                          const Text(
                            "Создатель:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(creatorLogin),

                          const Text(
                            "Режим доступа:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(roleText),

                          const Text(
                            "Дата создания:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(createdAt),

                          const Text(
                            "Дата изменения:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(updatedAt),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _urlController,
                      readOnly: !canEdit,
                      decoration: const InputDecoration(
                        labelText: "Целевая ссылка",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _descriptionController,
                      readOnly: !canEdit,
                      decoration: const InputDecoration(
                        labelText: "Описание (опционально)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (canEdit)
                          ElevatedButton(
                            onPressed: _updateLink,
                            child: const Text(
                              "Обновить",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        if (canDelete)
                          ElevatedButton(
                            onPressed: _deleteLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                241,
                                244,
                                67,
                                54,
                              ),
                            ),
                            child: const Text(
                              "Удалить",
                              style: TextStyle(
                                color: Color.fromARGB(240, 255, 255, 255),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
