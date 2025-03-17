import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;

class StatisticsPage extends StatefulWidget {
  final String linkId;

  const StatisticsPage({super.key, required this.linkId});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<FlSpot> _chartData = [];
  List<String> _labels = [];
  String _timeScale = 'hour';
  String _chartType = 'line';

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    // final response = await http.get(
    //   Uri.parse('https://your-api.com/api/v1/link-stat/${widget.linkId}/stats?timeScale=$_timeScale'),
    // );

    const statusCode = 200;

    if (statusCode == 200) {
      // final data = json.decode(response.body);

      Map<String, dynamic> data = {
        "labels": [
          "20-02-2025",
          "21-02-2025",
          "22-02-2025",
          "23-02-2025",
          "24-02-2025",
          "25-02-2025",
          "26-02-2025",
          "27-02-2025",
          "28-02-2025",
          "01-03-2025",
          "02-03-2025",
          "03-03-2025",
          "04-03-2025",
          "05-03-2025",
          "06-03-2025",
          "07-03-2025",
          "08-03-2025",
          "09-03-2025",
          "10-03-2025",
          "11-03-2025",
          "12-03-2025",
          "13-03-2025",
          "14-03-2025",
          "15-03-2025",
          "16-03-2025",
          "17-03-2025",
        ],
        "values": [
          20,
          40,
          30,
          30,
          60,
          60,
          70,
          0,
          0,
          0,
          0,
          70,
          0,
          0,
          0,
          0,
          0,
          0,
          50,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
        ],
      };

      setState(() {
        _labels = List<String>.from(data['labels']);
        _chartData = List.generate(
          data['values'].length,
          (index) => FlSpot(index.toDouble(), data['values'][index].toDouble()),
        );
      });
    } else {
      // Обработать ошибку
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Статистика")),
      body: Column(
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
                        _fetchStatistics();
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'hour', child: Text('Час')),
                    DropdownMenuItem(value: 'day', child: Text('День')),
                    DropdownMenuItem(value: 'month', child: Text('Месяц')),
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
                      setState(() {
                        _chartType = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'line', child: Text('Линейный')),
                    DropdownMenuItem(value: 'bar', child: Text('Столбчатый')),
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
                  width: _labels.length * 50.0,
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
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      return index >= 0 &&
                                              index < _labels.length
                                          ? RotatedBox(
                                            quarterTurns:
                                                0, // Поворот подписей на 45 градусов
                                            child: Container(
                                              padding: const EdgeInsets.all(
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
                                        40, // Увеличиваем пространство для меток по оси X
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
                            ),
                          )
                          : BarChart(
                            BarChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
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
                                              padding: const EdgeInsets.all(
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
                                      borderRadius: BorderRadius.circular(0),
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
