import 'package:stud_short_url_mobile/report-access-roles/report_access_roles.dart';

import 'short_link.dto.dart';

class ReportWithPermissionsDto {
  final String id;
  final String name;
  final String createdAt;
  final String createdByUserId;
  final ReportAccessRole role;
  final CreatorUser creatorUser;
  final List<ShortLinkDto> shortLinks;

  ReportWithPermissionsDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdByUserId,
    required this.role,
    required this.creatorUser,
    required this.shortLinks,
  });

  factory ReportWithPermissionsDto.fromJson(Map<String, dynamic> json) {
    return ReportWithPermissionsDto(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      createdByUserId: json['createdByUserId'],
      role: ReportAccessRole.values.firstWhere((e) => e.name == json['role']),
      creatorUser: CreatorUser.fromJson(json['creatorUser']),
      shortLinks: (json['shortLinks'] as List<dynamic>)
          .map((e) => ShortLinkDto.fromJson(e['shortLink']))
          .toList(),
    );
  }
}

class CreatorUser {
  final String id;
  final String login;

  CreatorUser({required this.id, required this.login});

  factory CreatorUser.fromJson(Map<String, dynamic> json) {
    return CreatorUser(
      id: json['id'],
      login: json['login'],
    );
  }
}
