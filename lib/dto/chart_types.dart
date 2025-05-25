enum ChartGranularity {
  hour('Час'),
  day('День'),
  month('Месяц');

  final String label;
  const ChartGranularity(this.label);
}

enum ChartType {
  line('Линейный'),
  bar('Столбчатый');

  final String label;
  const ChartType(this.label);
}

enum ChartPeriod {
  last24h('Последние 24 часа'),
  last7d('Последние 7 дней'),
  last30d('Последние 30 дней'),
  last365d('Последние 365 дней'),
  allTime('За все время'),
  custom('Произвольный период');

  final String label;
  const ChartPeriod(this.label);
}

enum ReportRoles {
  viewer('Просмотр'),
  editor('Редактирование'),
  admin('Администрирование');

  final String label;
  const ReportRoles(this.label);
}

ChartGranularity chartGranularityFromString(String value) {
  return ChartGranularity.values.firstWhere((e) => e.name == value);
}

ChartType chartTypeFromString(String value) {
  return ChartType.values.firstWhere((e) => e.name == value);
}

ChartPeriod chartPeriodFromString(String value) {
  return ChartPeriod.values.firstWhere((e) => e.name == value);
}

ReportRoles reportRoleFromString(String value) {
  return ReportRoles.values.firstWhere((e) => e.name == value);
}
