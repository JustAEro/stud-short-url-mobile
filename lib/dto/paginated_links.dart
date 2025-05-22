import 'link_item.dart';

class PaginatedLinks {
  final List<LinkItem> items;
  final bool hasMore;

  PaginatedLinks({required this.items, required this.hasMore});

  factory PaginatedLinks.fromJson(Map<String, dynamic> json) {
    return PaginatedLinks(
      items: (json['data'] as List).map((e) => LinkItem.fromJson(e)).toList(),
      hasMore: (json['currentPage'] as int) < (json['totalPages'] as int),
    );
  }
}

