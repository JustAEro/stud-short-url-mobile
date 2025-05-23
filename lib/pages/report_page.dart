import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/report-access-roles/report_access_roles.dart';
import 'report_statistics_page.dart';
import 'edit_report_page.dart';
import 'report_permissions_page.dart';
import 'share_report_page.dart';

class ReportPage extends StatefulWidget {
  final String reportId;

  const ReportPage({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Map<String, dynamic>? reportData;
  int _selectedIndex = 0;
  bool _isLoading = true;

  final _dio = DioClient().dio;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get('/api/v1/reports/${widget.reportId}');

      if (response.statusCode == 200) {
        setState(() {
          reportData = response.data;
        });
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки отчета')),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (reportData == null) {
      return const Scaffold(
        body: Center(child: Text('Не удалось загрузить отчет')),
      );
    }

    final role = parseReportRole(reportData?['role']);
    final bool canEdit = role == ReportAccessRole.editor || role == ReportAccessRole.admin;
    final bool canManagePermissions = role == ReportAccessRole.admin;

    return Scaffold(
      body: [
        ReportStatisticsPage(reportId: widget.reportId),
        EditReportPage(reportId: widget.reportId),
        if (canManagePermissions)
          ReportPermissionsPage(
            reportId: widget.reportId,
          ),
        ShareReportPage(reportId: widget.reportId),
      ][_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(110, 33, 149, 243),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
          if (canEdit)
            const NavigationDestination(
              icon: Icon(Icons.edit),
              label: 'Изменение',
            )
          else
            const NavigationDestination(
              icon: Icon(Icons.info),
              label: 'Информация',
            ),
          if (canManagePermissions)
            const NavigationDestination(
              icon: Icon(Icons.lock),
              label: 'Доступ',
            ),
          const NavigationDestination(
            icon: Icon(Icons.share),
            label: 'Поделиться',
          ),
        ],
      ),
    );
  }
}
