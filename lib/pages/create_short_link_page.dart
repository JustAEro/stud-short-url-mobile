import 'package:flutter/material.dart';

class CreateShortLinkPage extends StatefulWidget {
  const CreateShortLinkPage({super.key});

  @override
  State<CreateShortLinkPage> createState() => _CreateShortLinkPageState();
}

class _CreateShortLinkPageState extends State<CreateShortLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _longUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String longUrl = _longUrlController.text;
      final String description = _descriptionController.text;

      print('Создана короткая ссылка для: $longUrl с описанием: $description');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ссылка успешно создана!')));

      Navigator.pop(context);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _longUrlController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Создать короткую ссылку',
          style: TextStyle(fontSize: 20),
        ),
      ),

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
                  labelText: 'Описание (необязательно)',
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
              TextButton(
                onPressed: _resetForm,
                child: const Text(
                  'Сброс',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
