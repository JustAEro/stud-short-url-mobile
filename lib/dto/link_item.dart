class LinkItem {
  final String id;
  final String shortKey;
  final String description;
  final String longLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdByUserId;

  LinkItem({
    required this.id,
    required this.shortKey,
    required this.description,
    required this.longLink,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
  });

  factory LinkItem.fromJson(Map<String, dynamic> json) {
    return LinkItem(
      id: json['id'],
      shortKey: json['shortKey'],
      description: json['description'],
      longLink: json['longLink'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      createdByUserId: json['createdByUserId'],
    );
  }
}
