import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/chart_types.dart';
import 'package:stud_short_url_mobile/dto/full_report_dto.dart';
import 'package:stud_short_url_mobile/shared/always_visible_scroll_behavoir.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:stud_short_url_mobile/widgets/build_stats_section.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stud_short_url_mobile/widgets/report_chart_settings_bar.dart';

class ReportStatisticsPage extends StatefulWidget {
  final String reportId;

  const ReportStatisticsPage({super.key, required this.reportId});

  @override
  State<ReportStatisticsPage> createState() => _ReportStatisticsPageState();
}

class _ReportStatisticsPageState extends State<ReportStatisticsPage> {
  bool _isLoading = true;

  FullReportDto? _reportStats;

  ChartGranularity? _granularity;
  ChartType? _chartTypeEnum;
  ChartPeriod? _periodType;
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _canEdit = false;

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

  Future<void> _fetchReportStats() async {
    setState(() => _isLoading = true);

    try {
      print(DateTime.now().timeZoneOffset.inMinutes);
      final offset = DateTime.now().timeZoneOffset.inMinutes;
      final response = await _dio.get(
        '/api/v1/reports/${widget.reportId}/stats?timezoneOffsetInMinutes=${-offset}',
      );
      print(response.data);
      if (response.statusCode == 200) {
        setState(() {
          _reportStats = FullReportDto.fromJson(response.data);

          //print(_reportStats!.linksStats[0].labels.last);

          _granularity = _reportStats!.timeScale;
          _chartTypeEnum = _reportStats!.chartType;
          _periodType = _reportStats!.periodType;
          _customStart = _reportStats!.customStart;
          _customEnd = _reportStats!.customEnd;
          _canEdit =
              _reportStats!.role == ReportRoles.editor ||
              _reportStats!.role == ReportRoles.admin;
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

  Future<void> _updateReport({
    required ChartGranularity granularity,
    required ChartType chartType,
    required ChartPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    setState(() => _isLoading = true);

    try {
      final dio = DioClient().dio;

      final data = {
        'name': _reportStats!.name,
        'shortLinkIds': _reportStats!.shortLinks.map((l) => l.id).toList(),
        'timeScale': granularity.name,
        'chartType': chartType.name,
        'periodType': period.name,
        'customStart': startDate?.toUtc().toIso8601String(),
        'customEnd': endDate?.toUtc().toIso8601String(),
      };

      print(data);

      await dio.put('/api/v1/reports/${widget.reportId}', data: data);

      await _fetchReportStats();
    } catch (e) {
      print('Ошибка при обновлении отчета: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при обновлении отчета')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Color> _generateColors(int count) {
    return List<Color>.generate(count, (i) {
      final hue = (360 / count) * i;
      return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
    });
  }

  Widget _buildCombinedChart() {
    if (_reportStats == null || _reportStats!.linksStats.isEmpty) {
      return const Text("Нет данных для отображения графика.");
    }

    final labels = _reportStats!.linksStats.first.labels;
    final chartWidth = labels.length * 120.0;
    final colors = _generateColors(_reportStats!.linksStats.length);

    final lineBars = <LineChartBarData>[];
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < labels.length; i++) {
      final barRods = <BarChartRodData>[];

      for (int j = 0; j < _reportStats!.linksStats.length; j++) {
        final stat = _reportStats!.linksStats[j];
        if (i < stat.values.length) {
          final value = stat.values[i].toDouble();
          barRods.add(
            BarChartRodData(
              toY: value,
              color: colors[j],
              width: 12,
              borderRadius: BorderRadius.circular(0),
            ),
          );
        }
      }

      barGroups.add(BarChartGroupData(x: i, barRods: barRods));
    }

    for (int i = 0; i < _reportStats!.linksStats.length; i++) {
      final stat = _reportStats!.linksStats[i];
      final spots = List.generate(
        stat.values.length,
        (index) => FlSpot(index.toDouble(), stat.values[index].toDouble()),
      );

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 3,
          color: colors[i],
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            padding: const EdgeInsets.fromLTRB(8, 8, 50, 8),
            child: SizedBox(
              width: chartWidth,
              child:
                  _chartTypeEnum == ChartType.line
                      ? LineChart(
                        LineChartData(
                          lineBarsData: lineBars,
                          gridData: FlGridData(show: true),
                          titlesData: _buildTitlesData(labels),
                          borderData: FlBorderData(show: true),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipColor: (_) => Colors.black87,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final stat =
                                      _reportStats!.linksStats[spot.barIndex];
                                  return LineTooltipItem(
                                    '${stat.description.isNotEmpty ? stat.description : stat.shortKey}: ${spot.y.toInt()}',
                                    TextStyle(color: spot.bar.color),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      )
                      : BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          gridData: FlGridData(show: true),
                          titlesData: _buildTitlesData(labels),
                          borderData: FlBorderData(show: true),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipColor: (_) => Colors.black87,
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipRoundedRadius: 4,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final link = _reportStats!.linksStats[rodIndex];
                                return BarTooltipItem(
                                  '${link.description.isNotEmpty ? link.description : link.shortKey}: ${rod.toY.toInt()}',
                                  TextStyle(color: colors[rodIndex]),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: List.generate(_reportStats!.linksStats.length, (index) {
            final stat = _reportStats!.linksStats[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  stat.description.isNotEmpty
                      ? stat.description
                      : stat.shortKey,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  FlTitlesData _buildTitlesData(List<String> labels) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (value % 1 != 0 || index < 0 || index >= labels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(labels[index], style: const TextStyle(fontSize: 10)),
            );
          },
          reservedSize: 50,
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildPerLinkDetailedStats() {
    if (_reportStats == null || _reportStats!.linksStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final linkStat in _reportStats!.linksStats) ...[
          const SizedBox(height: 32),
          Text(
            'Статистика по ссылке: ${linkStat.description.isNotEmpty ? linkStat.description : linkStat.shortKey}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          buildStatsSection(
            'Устройства',
            Map.fromEntries(
              linkStat.detailedStats.byDevice.map(
                (e) => MapEntry(e.deviceType, e.count),
              ),
            ),
          ),
          buildStatsSection(
            'Браузеры',
            Map.fromEntries(
              linkStat.detailedStats.byBrowser.map(
                (e) => MapEntry(e.browser, e.count),
              ),
            ),
          ),
          buildStatsSection(
            'Источники переходов',
            Map.fromEntries(
              linkStat.detailedStats.byReferrer.map(
                (e) => MapEntry(e.referrer, e.count),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _exportReport(String format) async {
    try {
      final offset = DateTime.now().timeZoneOffset.inMinutes;
      final response = await _dio.get<List<int>>(
        '/api/v1/reports/${widget.reportId}/export',
        queryParameters: {'format': format, 'timezoneOffsetInMinutes': -offset},
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Файл сохранен: $savedPath")));

      await OpenFile.open(savedPath);
    } catch (e) {
      print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка при экспорте отчета")),
      );
    }
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
                      /*
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
                      */
                      if (_reportStats != null)
                        ReportChartSettingsBar(
                          initialGranularity: _granularity!,
                          initialChartType: _chartTypeEnum!,
                          initialPeriod: _periodType!,
                          initialStartDate: _customStart,
                          initialEndDate: _customEnd,
                          isEditable: _canEdit,
                          onSave: ({
                            required ChartGranularity granularity,
                            required ChartType chartType,
                            required ChartPeriod period,
                            DateTime? startDate,
                            DateTime? endDate,
                          }) async {
                            await _updateReport(
                              granularity: granularity,
                              chartType: chartType,
                              period: period,
                              startDate: startDate,
                              endDate: endDate,
                            );
                            await _fetchReportStats(); // перезагрузить статистику после обновления
                          },
                        ),

                      if (_reportStats!.aggregate.total > 0)
                        _buildCombinedChart(),
                      const SizedBox(height: 24),

                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(
                            Icons.bar_chart,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Всего переходов',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            _reportStats!.aggregate.total.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                      _buildPerLinkDetailedStats(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(110, 33, 149, 243),
        onPressed:
            null, // сам onPressed не нужен, он будет обработан внутри PopupMenuButton
        tooltip: 'Экспорт отчета',
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.download, color: Colors.black87),
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
      ),
    );
  }
}
