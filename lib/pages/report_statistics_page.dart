import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/full_report_dto.dart';
import 'package:stud_short_url_mobile/shared/always_visible_scroll_behavoir.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:stud_short_url_mobile/widgets/build_stats_section.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

class ReportStatisticsPage extends StatefulWidget {
  final String reportId;

  const ReportStatisticsPage({super.key, required this.reportId});

  @override
  State<ReportStatisticsPage> createState() => _ReportStatisticsPageState();
}

class _ReportStatisticsPageState extends State<ReportStatisticsPage> {
  bool _isLoading = true;
  String _timeScale = 'hour';
  String _chartType = 'line';

  FullReportDto? _reportStats;

  final _dio = DioClient().dio;

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReportStats();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updateChartType(String newType) {
    setState(() {
      _chartType = newType;
    });
  }

  Future<void> _fetchReportStats() async {
    setState(() => _isLoading = true);

    try {
      final response = await _dio.get(
        '/api/v1/reports/${widget.reportId}/stats?timeScale=$_timeScale',
      );
      if (response.statusCode == 200) {
        setState(() {
          _reportStats = FullReportDto.fromJson(response.data);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка загрузки статистики отчета")),
        );
      }
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ошибка при запросе")));
    } finally {
      setState(() => _isLoading = false);
    }
  }


Future<void> _exportReport(String format) async {
  try {
    final response = await _dio.get<List<int>>(
      '/api/v1/reports/${widget.reportId}/export',
      queryParameters: {'format': format, 'timeScale': _timeScale},
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = Uint8List.fromList(response.data!);

    // Открыть диалог сохранения файла и сразу передать bytes
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Сохранить отчет как',
      fileName: 'report_${widget.reportId}.$format',
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: [format],
    );

    if (savedPath == null) {
      // Пользователь отменил выбор
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Файл сохранен: $savedPath")),
    );

    await OpenFile.open(savedPath);
  } catch (e) {
    print(e);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ошибка при экспорте отчета")),
    );
  }
}

  Widget _buildClicksChart(LinkStatReportDto stat) {
    final spots = List.generate(
      stat.values.length,
      (index) => FlSpot(index.toDouble(), stat.values[index].toDouble()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Переходы по ссылке: ${stat.shortKey}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        PopupMenuButton<String>(
          icon: const Icon(Icons.download),
          onSelected: (format) => _exportReport(format),
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'csv', child: Text('Экспорт в CSV')),
                const PopupMenuItem(
                  value: 'xlsx',
                  child: Text('Экспорт в XLSX'),
                ),
              ],
        ),

        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = stat.labels.length * 120.0;
            final viewportWidth = constraints.maxWidth;

            return Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,

              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                padding: const EdgeInsets.fromLTRB(8, 8, 50, 8),
                child: SizedBox(
                  height: 250,
                  width:
                      chartWidth < viewportWidth
                          ? viewportWidth + 1
                          : chartWidth,
                  child: _buildChart(stat, spots),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChart(LinkStatReportDto stat, List<FlSpot> spots) {
    return _chartType == 'line'
        ? LineChart(
          LineChartData(
            clipData: FlClipData.none(),
            gridData: FlGridData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                barWidth: 3,
                color: Colors.blue,
                belowBarData: BarAreaData(
                  show: false,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
            minX: 0,
            maxX: spots.isNotEmpty ? spots.length - 1.0 : 1,
            minY: 0,
            maxY:
                spots.isNotEmpty
                    ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1
                    : 1,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (value % 1 != 0) return const SizedBox.shrink();
                    if (index < 0 || index >= stat.labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        left: 4.0,
                        right: 4.0,
                      ),
                      child: Text(
                        stat.labels[index],
                        style: const TextStyle(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  reservedSize: 60,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
          ),
        )
        : BarChart(
          BarChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    return index >= 0 && index < stat.labels.length
                        ? RotatedBox(
                          quarterTurns: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              stat.labels[index],
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            barGroups: List.generate(
              spots.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: spots[index].y,
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.blue,
                    width: 22.0,
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: "Статистика"),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reportStats == null
              ? const Center(child: Text("Нет данных"))
              : ScrollConfiguration(
                behavior: AlwaysVisibleScrollBehavior(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10.0,
                        children: [
                          Text(
                            "Гранулярность:",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16, // Указываем размер шрифта
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: _timeScale,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _timeScale = newValue;
                                  });

                                  _fetchReportStats();
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'hour',
                                  child: Text('Час'),
                                ),
                                DropdownMenuItem(
                                  value: 'day',
                                  child: Text('День'),
                                ),
                                DropdownMenuItem(
                                  value: 'month',
                                  child: Text('Месяц'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Тип графика:",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16, // Указываем размер шрифта
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: _chartType,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _updateChartType(newValue);
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'line',
                                  child: Text('Линейный'),
                                ),
                                DropdownMenuItem(
                                  value: 'bar',
                                  child: Text('Столбчатый'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Text(
                        "Общее количество переходов: ${_reportStats!.aggregate.total}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._reportStats!.linksStats.map(_buildClicksChart),
                      const SizedBox(height: 24),
                      buildStatsSection(
                        'Устройства',
                        Map.fromEntries(
                          _reportStats!.aggregate.byDevice.map(
                            (e) => MapEntry(e.deviceType, e.count),
                          ),
                        ),
                      ),

                      buildStatsSection(
                        'Браузеры',
                        Map.fromEntries(
                          _reportStats!.aggregate.byBrowser.map(
                            (e) => MapEntry(e.browser, e.count),
                          ),
                        ),
                      ),

                      buildStatsSection(
                        'Источники переходов',
                        Map.fromEntries(
                          _reportStats!.aggregate.byReferrer.map(
                            (e) => MapEntry(e.referrer, e.count),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
