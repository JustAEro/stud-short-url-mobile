import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stud_short_url_mobile/dto/chart_types.dart';

class ReportChartSettingsBar extends StatefulWidget {
  final ChartGranularity initialGranularity;
  final ChartType initialChartType;
  final ChartPeriod initialPeriod;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool isEditable;
  final Future<void> Function({
    required ChartGranularity granularity,
    required ChartType chartType,
    required ChartPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  })
  onSave;

  const ReportChartSettingsBar({
    super.key,
    required this.initialGranularity,
    required this.initialChartType,
    required this.initialPeriod,
    this.initialStartDate,
    this.initialEndDate,
    required this.isEditable,
    required this.onSave,
  });

  @override
  State<ReportChartSettingsBar> createState() => _ReportChartSettingsBarState();
}

class _ReportChartSettingsBarState extends State<ReportChartSettingsBar> {
  late ChartGranularity _granularity;
  late ChartType _chartType;
  late ChartPeriod _period;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _granularity = widget.initialGranularity;
    _chartType = widget.initialChartType;
    _period = widget.initialPeriod;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  bool get _hasChanges {
    return _granularity != widget.initialGranularity ||
        _chartType != widget.initialChartType ||
        _period != widget.initialPeriod ||
        (_period == ChartPeriod.custom &&
            (_startDate != widget.initialStartDate ||
                _endDate != widget.initialEndDate));
  }

  Future<void> _selectCustomDates() async {
    final now = DateTime.now();

    // Выбор начала
    final pickedStartDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDate: _startDate ?? now,
    );

    if (pickedStartDate == null) return;

    if (!mounted) return;

    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate ?? DateTime.now()),
    );

    if (pickedStartTime == null) return;

    if (!mounted) return;

    // Выбор окончания
    final pickedEndDate = await showDatePicker(
      context: context,
      firstDate: pickedStartDate,
      lastDate: now,
      initialDate: _endDate ?? pickedStartDate,
    );

    if (pickedEndDate == null) return;

    if (!mounted) return;

    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate ?? DateTime.now()),
    );

    if (pickedEndTime == null) return;

    final startDateTime = DateTime(
      pickedStartDate.year,
      pickedStartDate.month,
      pickedStartDate.day,
      pickedStartTime.hour,
      pickedStartTime.minute,
    );

    final endDateTime = DateTime(
      pickedEndDate.year,
      pickedEndDate.month,
      pickedEndDate.day,
      pickedEndTime.hour,
      pickedEndTime.minute,
    );

    setState(() {
      _startDate = startDateTime;
      _endDate = endDateTime;
    });
  }

  void _resetToInitial() {
    setState(() {
      _granularity = widget.initialGranularity;
      _chartType = widget.initialChartType;
      _period = widget.initialPeriod;
      _startDate = widget.initialStartDate;
      _endDate = widget.initialEndDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = widget.isEditable;
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
                  child: DropdownButton<ChartGranularity>(
                    value: _granularity,
                    onChanged:
                        isEditable
                            ? (val) => setState(() => _granularity = val!)
                            : null,
                    items:
                        ChartGranularity.values.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g.label),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10.0,
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
                  child: DropdownButton<ChartType>(
                    value: _chartType,
                    onChanged:
                        isEditable
                            ? (val) => setState(() => _chartType = val!)
                            : null,
                    items:
                        ChartType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10.0,
              children: [
                Text(
                  "Период:",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16, // Указываем размер шрифта
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<ChartPeriod>(
                    value: _period,
                    onChanged:
                        isEditable
                            ? (val) async {
                              if (val == ChartPeriod.custom) {
                                await _selectCustomDates();
                              }
                              setState(() => _period = val!);
                            }
                            : null,
                    items:
                        ChartPeriod.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.label),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),

            if (_period == ChartPeriod.custom &&
                _startDate != null &&
                _endDate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${dateFormat.format(_startDate!)} — ${dateFormat.format(_endDate!)}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
          ],
        ),
        if (_hasChanges && isEditable)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetToInitial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(241, 244, 67, 54),
                  ),
                  child: const Text(
                    "Отмена",
                    style: TextStyle(color: Color.fromARGB(240, 255, 255, 255)),
                  ),
                ),

                const SizedBox(width: 32),

                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      granularity: _granularity,
                      chartType: _chartType,
                      period: _period,
                      startDate:
                          _period == ChartPeriod.custom ? _startDate : null,
                      endDate: _period == ChartPeriod.custom ? _endDate : null,
                    );
                  },
                  child: const Text(
                    "Сохранить",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
