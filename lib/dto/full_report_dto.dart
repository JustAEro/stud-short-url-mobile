import 'package:stud_short_url_mobile/dto/chart_types.dart';

import 'short_link.dto.dart';

class LinkStatClicksDto {
  final List<String> labels;
  final List<int> values;

  LinkStatClicksDto({required this.labels, required this.values});

  factory LinkStatClicksDto.fromJson(Map<String, dynamic> json) {
    return LinkStatClicksDto(
      labels: List<String>.from(json['labels']),
      values: List<int>.from(json['values']),
    );
  }
}

class DeviceStat {
  final String deviceType;
  final int count;

  DeviceStat({required this.deviceType, required this.count});

  factory DeviceStat.fromJson(Map<String, dynamic> json) {
    return DeviceStat(
      deviceType: json['deviceType'],
      count: json['_count']['_all'],
    );
  }
}

class BrowserStat {
  final String browser;
  final int count;

  BrowserStat({required this.browser, required this.count});

  factory BrowserStat.fromJson(Map<String, dynamic> json) {
    return BrowserStat(
      browser: json['browser'],
      count: json['_count']['_all'],
    );
  }
}

class ReferrerStat {
  final String referrer;
  final int count;

  ReferrerStat({required this.referrer, required this.count});

  factory ReferrerStat.fromJson(Map<String, dynamic> json) {
    return ReferrerStat(
      referrer: json['referrer'] ?? 'Неизвестно',
      count: json['_count']['_all'],
    );
  }
}

class LinkDetailedStatsDto {
  final int total;
  final List<DeviceStat> byDevice;
  final List<BrowserStat> byBrowser;
  final List<ReferrerStat> byReferrer;

  LinkDetailedStatsDto({
    required this.total,
    required this.byDevice,
    required this.byBrowser,
    required this.byReferrer,
  });

  factory LinkDetailedStatsDto.fromJson(Map<String, dynamic> json) {
    return LinkDetailedStatsDto(
      total: json['total'],
      byDevice: (json['byDevice'] as List)
          .map((item) => DeviceStat.fromJson(item))
          .toList(),
      byBrowser: (json['byBrowser'] as List)
          .map((item) => BrowserStat.fromJson(item))
          .toList(),
      byReferrer: (json['byReferrer'] as List)
          .map((item) => ReferrerStat.fromJson(item))
          .toList(),
    );
  }
}

class LinkStatReportDto extends LinkStatClicksDto {
  final String shortLinkId;
  final String shortKey;
  final String description;
  final LinkDetailedStatsDto detailedStats;

  LinkStatReportDto({
    required this.shortLinkId,
    required this.description,
    required this.shortKey,
    required super.labels,
    required super.values,
    required this.detailedStats,
  });

  factory LinkStatReportDto.fromJson(Map<String, dynamic> json) {
    return LinkStatReportDto(
      shortLinkId: json['shortLinkId'],
      shortKey: json['shortKey'],
      labels: List<String>.from(json['labels']),
      values: List<int>.from(json['values']),
      description: json['description'],
      detailedStats: LinkDetailedStatsDto(
        total: json['total'],
        byDevice: (json['byDevice'] as List)
            .map((item) => DeviceStat.fromJson(item))
            .toList(),
        byBrowser: (json['byBrowser'] as List)
            .map((item) => BrowserStat.fromJson(item))
            .toList(),
        byReferrer: (json['byReferrer'] as List)
            .map((item) => ReferrerStat.fromJson(item))
            .toList(),
      ),
    );
  }
}

class FullReportDto {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdByUserId;
  final List<ShortLinkDto> shortLinks;
  final ChartGranularity timeScale; // 'hour' | 'day' | 'month'
  final ChartType chartType; // 'line' | 'bar'
  final ChartPeriod periodType; // 'last24h' | 'last7d' | 'last30d' | 'last365d' | 'allTime' | 'custom'
  final DateTime? customStart;
  final DateTime? customEnd;
  final ReportRoles role; // 'viewer' | 'editor' | 'admin'
  final LinkDetailedStatsDto aggregate;
  final List<LinkStatReportDto> linksStats;

  FullReportDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.shortLinks,
    required this.timeScale,
    required this.chartType,
    required this.periodType,
    required this.role,
    this.customStart,
    this.customEnd,
    required this.aggregate,
    required this.linksStats,
  });

  factory FullReportDto.fromJson(Map<String, dynamic> json) {
    return FullReportDto(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      createdByUserId: json['createdByUserId'],
      shortLinks: (json['shortLinks'] as List)
          .map((e) => ShortLinkDto.fromJson(e['shortLink']))
          .toList(),
      timeScale: chartGranularityFromString(json['timeScale']),
      chartType: chartTypeFromString(json['chartType']),
      periodType: chartPeriodFromString(json['periodType']),
      customStart: json['customStart'] != null
          ? DateTime.parse(json['customStart']).toLocal()
          : null,
      customEnd: json['customEnd'] != null
          ? DateTime.parse(json['customEnd']).toLocal()
          : null,
      role: reportRoleFromString(json['role']),
      aggregate: LinkDetailedStatsDto.fromJson(json['aggregate']),
      linksStats: (json['linksStats'] as List)
          .map((item) => LinkStatReportDto.fromJson(item))
          .toList(),
    );
  }
}

