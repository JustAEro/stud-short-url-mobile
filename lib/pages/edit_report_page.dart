import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/report_with_permissions.dart';
import 'package:stud_short_url_mobile/dto/short_link.dto.dart';
import 'package:stud_short_url_mobile/report-access-roles/report_access_roles.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:stud_short_url_mobile/widgets/link_selector.dart';

class EditReportPage extends StatefulWidget {
  final String reportId;

  const EditReportPage({super.key, required this.reportId});

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  List<String> _selectedLinkIds = [];
  List<ShortLinkDto> _initialSelectedLinks = [];
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  ReportAccessRole? _role;

  late ReportWithPermissionsDto _loadedReport;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _loading = true);

    try {
      final dio = DioClient().dio;
      final response = await dio.get('/api/v1/reports/${widget.reportId}');
      final report = ReportWithPermissionsDto.fromJson(response.data);

      _loadedReport = report;

      _nameController.text = report.name;
      _selectedLinkIds = List<String>.from(report.shortLinks.map((l) => l.id));
      _initialSelectedLinks = report.shortLinks;
      _role = report.role;
    } catch (e) {
      print('Ошибка при загрузке отчета: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить отчет')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onSelectionChanged(List<String> selected) {
    setState(() => _selectedLinkIds = selected);
  }

  bool get _canEdit =>
      _role == ReportAccessRole.editor || _role == ReportAccessRole.admin;
  bool get _isAdmin => _role == ReportAccessRole.admin;

  Future<void> _updateReport() async {
    if (_selectedLinkIds.isEmpty || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название и список ссылок обязательны')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final dio = DioClient().dio;
      await dio.put(
        '/api/v1/reports/${widget.reportId}',
        data: {
          'name': _nameController.text.trim(),
          'shortLinkIds': _selectedLinkIds,

          'timeScale': _loadedReport.timeScale.name,
          'chartType': _loadedReport.chartType.name,
          'periodType': _loadedReport.periodType.name,
          'customStart': _loadedReport.customStart?.toUtc().toIso8601String(),
          'customEnd': _loadedReport.customEnd?.toUtc().toIso8601String(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Отчет успешно обновлен')));

      await _loadReportData();
    } catch (e) {
      print('Ошибка при обновлении отчета: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при обновлении отчета')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Удаление отчета'),
            content: const Text('Вы уверены, что хотите удалить отчет?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      final dio = DioClient().dio;
      await dio.delete('/api/v1/reports/${widget.reportId}');
      if (!mounted) return;
      Navigator.pop(context, true); // выйти после удаления
    } catch (e) {
      print('Ошибка при удалении отчета: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении отчета')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        _loading
            ? 'Загрузка...'
            : _canEdit
            ? 'Редактирование'
            : 'Просмотр';

    return Scaffold(
      appBar: AuthenticatedAppBar(title: title),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      readOnly: !_canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Название отчета',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: LinkSelector(
                        initialSelectedIds: _selectedLinkIds,
                        initialSelectedLinks: _initialSelectedLinks,
                        onSelectionChanged: _onSelectionChanged,
                        canEdit: _canEdit,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_canEdit)
                          ElevatedButton(
                            onPressed: _updateReport,
                            child: const Text(
                              "Обновить",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        if (_isAdmin)
                          ElevatedButton(
                            onPressed: _deleteReport,
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
