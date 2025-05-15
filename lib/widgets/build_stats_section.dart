import 'package:flutter/material.dart';

Widget buildStatsSection(String title, Map<String, int> data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...data.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
      const SizedBox(height: 16),
    ],
  );
}