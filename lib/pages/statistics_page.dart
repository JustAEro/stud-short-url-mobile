import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';

import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:stud_short_url_mobile/widgets/build_stats_section.dart';

class StatisticsPage extends StatefulWidget {
  final String linkId;
  final String shortKey;

  const StatisticsPage({
    super.key,
    required this.linkId,
    required this.shortKey,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<FlSpot> _chartData = [];
  List<String> _labels = [];
  String _timeScale = 'day';
  String _chartType = 'line';
  bool _isLoading = true;
  Map<String, int> _deviceStats = {};
  Map<String, int> _browserStats = {};
  Map<String, int> _referrerStats = {};
  int _totalClicks = 0;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final _dio = DioClient().dio;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get(
        '/api/v1/link-stat/${widget.shortKey}/stats?timeScale=$_timeScale',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          _labels = List<String>.from(data['labels']);
          _chartData = List.generate(
            data['values'].length,
            (index) =>
                FlSpot(index.toDouble(), data['values'][index].toDouble()),
          );
        });
      } else {
        print(response.data);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки статистики')),
        );
      }

      final detailsResponse = await _dio.get(
        '/api/v1/link-stat/${widget.shortKey}/details',
      );

      if (detailsResponse.statusCode == 200) {
        final stats = detailsResponse.data;
        setState(() {
          _totalClicks = stats['total'];
          _deviceStats = {
            for (var item in stats['byDevice'])
              item['deviceType']: item['_count']['_all'],
          };
          _browserStats = {
            for (var item in stats['byBrowser'])
              item['browser']: item['_count']['_all'],
          };
          _referrerStats = {
            for (var item in stats['byReferrer'])
              item['referrer'] ?? 'Неизвестно': item['_count']['_all'],
          };
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки статистики')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateChartType(String newType) {
    setState(() {
      _chartType = newType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Статистика'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                                    _fetchStatistics();
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

                        // Легенда
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                // margin: EdgeInsets.only(top: 8),
                                width: 20,
                                height: 10,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Количество переходов',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          controller: _horizontalScrollController,
                          scrollbarOrientation: ScrollbarOrientation.bottom,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(8, 8, 30, 8),
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width:
                                  (_labels.length * 120.0) <
                                          MediaQuery.of(context).size.width
                                      ? MediaQuery.of(context).size.width
                                      : _labels.length * 120.0,
                              height: 250,
                              child:
                                  _chartType == 'line'
                                      ? LineChart(
                                        LineChartData(
                                          clipData: FlClipData.none(),
                                          gridData: FlGridData(show: true),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ), // Убираем подписи справа
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ), // Убираем подписи сверху
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 1,
                                                getTitlesWidget: (value, meta) {
                                                  int index = value.toInt();

                                                  // Добавляем строгую проверку на целое значение
                                                  if (value % 1 != 0) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  if (index < 0 ||
                                                      index >= _labels.length) {
                                                    return const SizedBox.shrink();
                                                  }

                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 8.0,
                                                      bottom: 8.0,
                                                      left: 4.0,
                                                      right:
                                                          index ==
                                                                  _labels.length -
                                                                      1
                                                              ? 20.0
                                                              : 4.0,
                                                    ),
                                                    child: Text(
                                                      _labels[index],
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  );
                                                },

                                                reservedSize:
                                                    60, // Увеличиваем пространство для меток по оси X
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: true),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: _chartData,
                                              isCurved: false,
                                              barWidth: 3,
                                              color: Colors.blue,
                                              belowBarData: BarAreaData(
                                                show: false,
                                                color: Colors.blue.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                          minX: 0,
                                          maxX:
                                              _chartData.isNotEmpty
                                                  ? _chartData.length - 1.0
                                                  : 1,
                                          minY: 0,
                                          maxY:
                                              _chartData.isNotEmpty
                                                  ? _chartData
                                                          .map((e) => e.y)
                                                          .reduce(
                                                            (a, b) =>
                                                                a > b ? a : b,
                                                          ) +
                                                      1
                                                  : 1,
                                        ),
                                      )
                                      : BarChart(
                                        BarChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  int index = value.toInt();
                                                  return index >= 0 &&
                                                          index < _labels.length
                                                      ? RotatedBox(
                                                        quarterTurns: 0,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: Text(
                                                            _labels[index],
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 8,
                                                                ),
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
                                            _chartData.length,
                                            (index) => BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: _chartData[index].y,
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  color: Colors.blue,
                                                  width: 22.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),

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
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '$_totalClicks',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        buildStatsSection('Устройства', _deviceStats),
                        buildStatsSection('Браузеры', _browserStats),
                        buildStatsSection(
                          'Источники переходов',
                          _referrerStats,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
