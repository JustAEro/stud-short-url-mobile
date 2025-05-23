import 'package:flutter/material.dart';

class ShareReportPage extends StatelessWidget {
  final String reportId;

  const ShareReportPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Поделиться отчётом: $reportId'),
    );
  }
}
