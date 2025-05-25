import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:stud_short_url_mobile/widgets/link_selector.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  List<String> _selectedLinkIds = [];
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;

  void _onSelectionChanged(List<String> selected) {
    setState(() {
      _selectedLinkIds = selected;
    });
  }

  Future<void> _submitReport() async {
    if (_selectedLinkIds.isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название и выберите ссылки')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        '/api/v1/reports',
        data: {
          'name': _nameController.text.trim(),
          'shortLinkIds': _selectedLinkIds,
        },
      );

      // Можно обработать результат, например:
      //final reportId = response.data['id'];

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Отчет успешно создан')));

      // Навигация на страницу отчета (если она есть)
      // Navigator.pushNamed(context, '/reports/$reportId');

      // Или вернуться назад:
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка при создании отчета: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при создании отчета')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Создание отчета'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название отчета',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LinkSelector(
                onSelectionChanged: _onSelectionChanged,
                canEdit: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _loading ? null : _submitReport,
          child:
              _loading
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                  : const Text(
                    'Создать отчет',
                    style: TextStyle(color: Colors.blue),
                  ),
        ),
      ),
    );
  }
}
