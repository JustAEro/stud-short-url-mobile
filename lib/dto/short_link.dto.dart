class ShortLinkDto {
  final String id;
  final String longLink;
  final String shortKey;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;

  ShortLinkDto({
    required this.id,
    required this.longLink,
    required this.shortKey,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
  });

  factory ShortLinkDto.fromJson(Map<String, dynamic> json) {
    return ShortLinkDto(
      id: json['id'],
      longLink: json['longLink'],
      shortKey: json['shortKey'],
      createdByUserId: json['createdByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      description: json['description'],
    );
  }
}