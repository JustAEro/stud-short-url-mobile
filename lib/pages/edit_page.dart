import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  final String linkId;
  const EditPage({super.key, required this.linkId});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isOwner = true; // Мок данных, измените на реальную логику

  @override
  void initState() {
    super.initState();
    // Инициализировать контроллеры с данными ссылки
    _urlController.text = "https://example.com"; // Мок данных
    _descriptionController.text = "Описание ссылки"; // Мок данных
  }

  // Моковая функция обновления данных
  void _updateLink() {
    final String updatedUrl = _urlController.text;
    final String updatedDescription = _descriptionController.text;

    // Мок обновления данных
    print("Обновленная ссылка: $updatedUrl, Описание: $updatedDescription");

    // В реальной версии, здесь будет запрос к серверу
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ссылка обновлена')));
  }

  // Моковая функция удаления ссылки
  void _deleteLink() {
    // Мок удаления ссылки
    print("Ссылка удалена");

    // В реальной версии, здесь будет запрос на сервер для удаления
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ссылка удалена')));

    // Возвращаемся на предыдущую страницу после удаления
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Редактирование")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Редактирование короткой ссылки: ${widget.linkId}"),
            const SizedBox(height: 16.0),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "Целевая ссылка",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Описание (опционально)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _updateLink,
                  child: const Text(
                    "Обновить",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                if (isOwner)
                  ElevatedButton(
                    onPressed: _deleteLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(241, 244, 67, 54),
                    ),
                    child: const Text(
                      "Удалить",
                      style: TextStyle(color: Color.fromARGB(240, 255, 255, 255)),
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
