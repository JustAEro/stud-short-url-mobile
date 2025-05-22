import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

import 'create_report_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];
  bool loading = false;

  final _dio = DioClient().dio;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await _dio.get(
        '/api/v1/reports'
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          reports = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error loading reports: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void openReportDetail(Map<String, dynamic> report) {
    // Пока просто выводим в консоль
    print('Открыть отчет: ${report['name']}');
    // TODO: Перейти на страницу подробного отчета
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Отчеты'),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : reports.isEmpty
              ? const Center(child: Text('У вас пока нет отчетов'))
              : ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ListTile(
                    title: Text(report['name'] ?? 'Без названия'),
                    subtitle: Text(
                      'Создан: ${report['createdAt'].toString().substring(0, 10)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => openReportDetail(report),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );

          if (result == true) {
            loadReports(); // обновить список после создания
          }
        },
        tooltip: 'Создать отчет',
        child: const Icon(Icons.add),
      ),
    );
  }
}
