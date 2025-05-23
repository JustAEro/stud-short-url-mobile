import 'package:flutter/material.dart';

class EditReportPage extends StatelessWidget {
  final String reportId;

  const EditReportPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Редактирование отчета: $reportId'),
    );
  }
}
