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
      referrer: json['referrer'] ?? 'Unknown',
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
  final LinkDetailedStatsDto detailedStats;

  LinkStatReportDto({
    required this.shortLinkId,
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
  final LinkDetailedStatsDto aggregate;
  final List<LinkStatReportDto> linksStats;

  FullReportDto({required this.aggregate, required this.linksStats});

  factory FullReportDto.fromJson(Map<String, dynamic> json) {
    return FullReportDto(
      aggregate: LinkDetailedStatsDto.fromJson(json['aggregate']),
      linksStats: (json['linksStats'] as List)
          .map((item) => LinkStatReportDto.fromJson(item))
          .toList(),
    );
  }
}
