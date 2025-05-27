import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

class ReportMetaInfoPage extends StatelessWidget {
  final String createdBy;
  final String accessMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportMetaInfoPage({
    super.key,
    required this.createdBy,
    required this.accessMode,
    required this.createdAt,
    required this.updatedAt,
  });

  String formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthenticatedAppBar(title: 'Информация'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // color: const Color.fromARGB(211, 94, 179, 248),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4, // Устанавливаем пропорции строк
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
            ),
            children: [
              const Text(
                "Создатель:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(createdBy),

              const Text(
                "Режим доступа:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(accessMode),

              const Text(
                "Дата создания:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(formatDateTime(createdAt)),

              const Text(
                "Дата изменения:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(formatDateTime(updatedAt)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildInfoRow(String label, String value) {
  //   return Row(
  //     children: [
  //       SizedBox(
  //         width: 140,
  //         child: Text(
  //           label,
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //       ),
  //       Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
  //     ],
  //   );
  // }
}
