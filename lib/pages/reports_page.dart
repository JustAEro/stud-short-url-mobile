import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];
  bool loading = false;

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
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/v1/reports'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
    );
  }
}
