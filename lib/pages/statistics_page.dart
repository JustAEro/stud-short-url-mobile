import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stud_short_url_mobile/services/auth_service.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

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
  String _timeScale = 'hour';
  String _chartType = 'line';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/api/v1/link-stat/${widget.shortKey}/stats?timeScale=$_timeScale',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _labels = List<String>.from(data['labels']);
          _chartData = List.generate(
            data['values'].length,
            (index) =>
                FlSpot(index.toDouble(), data['values'][index].toDouble()),
          );
        });
      } else {
        print(response.body);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки статистики')),
        );
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
              : Column(
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
                            DropdownMenuItem(value: 'hour', child: Text('Час')),
                            DropdownMenuItem(value: 'day', child: Text('День')),
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

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(8.0),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width:
                              _labels.length * 120.0 <
                                      MediaQuery.of(context).size.width
                                  ? MediaQuery.of(context).size.width
                                  : _labels.length * 120.0,
                          child:
                              _chartType == 'line'
                                  ? LineChart(
                                    LineChartData(
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
                                              return index >= 0 &&
                                                      index < _labels.length
                                                  ? RotatedBox(
                                                    quarterTurns:
                                                        0, // Поворот подписей на 45 градусов
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Text(
                                                        _labels[index],
                                                        style: const TextStyle(
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  : const SizedBox.shrink();
                                            },
                                            reservedSize:
                                                50, // Увеличиваем пространство для меток по оси X
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
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                      minX: 0,
                                      maxX:
                                          _chartData.isNotEmpty
                                              ? _chartData.length - 1
                                              : 1,
                                      minY: 0,
                                      maxY:
                                          _chartData.isNotEmpty
                                              ? _chartData
                                                      .map((e) => e.y)
                                                      .reduce(
                                                        (a, b) => a > b ? a : b,
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
                                                        style: const TextStyle(
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
                  ),
                ],
              ),
    );
  }
}
