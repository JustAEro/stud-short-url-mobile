import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

import 'short_link_page.dart';

class CreateShortLinkPage extends StatefulWidget {
  const CreateShortLinkPage({super.key});

  @override
  State<CreateShortLinkPage> createState() => _CreateShortLinkPageState();
}

class _CreateShortLinkPageState extends State<CreateShortLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _longUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String longUrl = _longUrlController.text;
      final String description = _descriptionController.text;

      final userInfo = await AuthService().getUserInfo();
      if (userInfo == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить информацию о пользователе'),
          ),
        );
        return;
      }

      try {
        final dio = DioClient().dio;

        final response = await dio.post(
          '/api/v1/short-links',
          data: {
            'login': userInfo['login'],
            'longLink': longUrl,
            'description': description,
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final String linkId = data['id'];
          final String shortKey = data['shortKey'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ShortLinkPage(linkId: linkId, shortKey: shortKey,),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка при создании ссылки: ${response.statusCode} ${response.data}',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании ссылки: $e')),
        );
      }
    }
  }

  // void _resetForm() {
  //   _formKey.currentState?.reset();
  //   _longUrlController.clear();
  //   _descriptionController.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Создать короткую ссылку'),

      resizeToAvoidBottomInset: false,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _longUrlController,
                decoration: const InputDecoration(
                  labelText: 'Целевая ссылка',
                  hintText: 'Введите URL',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ссылку';
                  }
                  if (!RegExp(
                    r'^(http|https):\/\/[^\s$.?#].[^\s]*$',
                  ).hasMatch(value)) {
                    return 'Введите корректный URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (Опционально)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text(
                  'Создать',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
