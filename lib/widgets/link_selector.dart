import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/link_item.dart';
import 'package:stud_short_url_mobile/dto/paginated_links.dart';
import 'package:stud_short_url_mobile/dto/short_link.dto.dart';

class LinkSelector extends StatefulWidget {
  final void Function(List<String>) onSelectionChanged;

  final List<String> initialSelectedIds;

  final List<ShortLinkDto> initialSelectedLinks;

  final bool canEdit;

  const LinkSelector({
    super.key,
    required this.onSelectionChanged,
    required this.canEdit,
    this.initialSelectedIds = const [],
    this.initialSelectedLinks = const [],
  });

  @override
  State<LinkSelector> createState() => _LinkSelectorState();
}

class _LinkSelectorState extends State<LinkSelector> {
  final ScrollController _scrollController = ScrollController();

  List<LinkItem> shortLinks = [];
  late Set<String> selectedIds;
  late List<LinkItem> initialLinks;
  bool loading = false;

  String sortBy = 'updatedAt';
  String sortDirection = 'desc';
  String searchQuery = '';
  int page = 1;
  final int limit = 5;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    initialLinks =
        widget.initialSelectedLinks
            .map(
              (link) => LinkItem(
                id: link.id,
                shortKey: link.shortKey,
                description: link.description,
                longLink: link.longLink,
                createdAt: link.createdAt,
                updatedAt: link.updatedAt,
                createdByUserId: link.createdByUserId,
              ),
            )
            .toList();
    selectedIds = widget.initialSelectedIds.toSet();
    _scrollController.addListener(_onScroll);
    loadShortLinks(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hasMore &&
        !loading) {
      page++;
      loadShortLinks();
    }
  }

  Future<void> loadShortLinks({bool reset = false}) async {
    setState(() {
      loading = true;
    });

    try {
      final dio = DioClient().dio;

      final response = await dio.get(
        '/api/v1/short-links',
        queryParameters: {
          'sortBy': sortBy,
          'sortDirection': sortDirection,
          'search': searchQuery,
          'page': page,
          'limit': limit,
        },
      );

      final paginated = PaginatedLinks.fromJson(response.data);

      setState(() {
        if (reset) {
          shortLinks = paginated.items;
        } else {
          shortLinks.addAll(paginated.items);
        }
        hasMore = paginated.hasMore;
      });
    } catch (e) {
      print('Error loading links: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onSelectChanged(bool? selected, String id) {
    setState(() {
      if (selected == true) {
        selectedIds.add(id);
      } else {
        selectedIds.remove(id);
      }
    });
    widget.onSelectionChanged(selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final allLinks = [
      ...initialLinks.where(
        (link) => !shortLinks.any((existing) => existing.id == link.id),
      ),
      ...shortLinks,
    ];

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Поиск (введите часть описания или ключа)",
          ),
          onChanged: (value) {
            searchQuery = value;
            page = 1;
            loadShortLinks(reset: true);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Сортировка:"),
            DropdownButton<String>(
              value: sortBy,
              items: const [
                DropdownMenuItem(
                  value: "updatedAt",
                  child: Text("Дата изменения"),
                ),
                DropdownMenuItem(
                  value: "createdAt",
                  child: Text("Дата создания"),
                ),
                DropdownMenuItem(value: "description", child: Text("Описание")),
              ],
              onChanged: (value) {
                sortBy = value!;
                page = 1;
                loadShortLinks(reset: true);
              },
            ),
            IconButton(
              icon: Icon(
                sortDirection == 'asc'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              onPressed: () {
                sortDirection = sortDirection == 'asc' ? 'desc' : 'asc';
                page = 1;
                loadShortLinks(reset: true);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              loading && shortLinks.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: allLinks.length,
                      itemBuilder: (context, index) {
                        final link = allLinks[index];

                        final shortUrl =
                          '${dotenv.env['SHORT_LINKS_WEB_APP_URL']}/${link.shortKey}';
                          
                        final displayText =
                            link.description.isNotEmpty
                                ? link.description
                                : link.shortKey;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: CheckboxListTile(
                            enabled: widget.canEdit,
                            activeColor: const Color.fromARGB(215, 33, 149, 243),
                            title: Text(displayText),
                            subtitle: Text(shortUrl),
                            value: selectedIds.contains(link.id),
                            onChanged:
                                (selected) =>
                                    onSelectChanged(selected, link.id),
                          ),
                        );
                      },
                    ),
                  ),
        ),
        if (loading && shortLinks.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
