import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

import 'create_report_page.dart';
import 'report_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];
  bool loading = false;

  String sortBy = 'updatedAt';
  String sortDirection = 'desc';
  String searchQuery = '';
  int page = 1;
  int limit = 5;
  int totalPages = 1;

  final ScrollController _scrollController = ScrollController();

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
        '/api/v1/reports?sortBy=$sortBy&sortDirection=$sortDirection&search=$searchQuery&page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          if (page == 1) {
            reports = List<Map<String, dynamic>>.from(data['data']);
          } else {
            reports.addAll(List<Map<String, dynamic>>.from(data['data']));
          }
          totalPages = data['totalPages'];
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

  void openReportDetail(Map<String, dynamic> report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPage(reportId: report['id']),
      ),
    );

    if (result == true) {
      // Если вернулись с обновлением отчета, перезагрузить список
      loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Отчеты'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Поиск (введите часть названия)",
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  page = 1; // Сбросить страницу при новом поиске
                });
                loadReports();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Сортировка:",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16, // Указываем размер шрифта
                  ),
                ),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: "updatedAt",
                      child: Text(
                        "Дата изменения",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "createdAt",
                      child: Text(
                        "Дата создания",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "name",
                      child: Text(
                        "Название",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                      page = 1; // Сбросить страницу при изменении сортировки
                    });

                    loadReports();
                  },
                ),

                IconButton(
                  icon: Icon(
                    sortDirection == 'asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      sortDirection = sortDirection == 'asc' ? 'desc' : 'asc';
                      page =
                          1; // Сбросить страницу при изменении направления сортировки
                    });

                    loadReports();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    page = 1; // Сбросить страницу при обновлении
                  });

                  await loadReports();
                },
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: reports.length + 1,
                    itemBuilder: (context, index) {
                      if (index == reports.length) {
                        if (page < totalPages) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Center(
                              child: SizedBox(
                                width:
                                    200, // Фиксированная ширина как у кнопки создания
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      page++;
                                    });
                                    loadReports();
                                  },
                                  child: const Text(
                                    'Загрузить ещё',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink(); // или пустое место, если больше страниц нет
                        }
                      }

                      final report = reports[index];

                      final createdAt = DateTime.parse(report['createdAt']);
                      final updatedAt = DateTime.parse(report['updatedAt']);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: GestureDetector(
                            onTap: () => openReportDetail(report),
                            child: Text(
                              report['name']?.toString().isNotEmpty == true
                                  ? report['name']
                                  : 'Без названия',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Дата создания: ${dateFormat.format(createdAt.toLocal())}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "Дата изменения: ${dateFormat.format(updatedAt.toLocal())}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => openReportDetail(report),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(110, 33, 149, 243),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );

          if (result == true) {
            loadReports(); // обновить список после создания
          }
        },
        tooltip: 'Создать отчёт',
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}
