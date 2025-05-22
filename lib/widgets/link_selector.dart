import 'package:flutter/material.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/link_item.dart';
import 'package:stud_short_url_mobile/dto/paginated_links.dart';

class LinkSelector extends StatefulWidget {
  final void Function(List<String>) onSelectionChanged;

  const LinkSelector({super.key, required this.onSelectionChanged});

  @override
  State<LinkSelector> createState() => _LinkSelectorState();
}

class _LinkSelectorState extends State<LinkSelector> {
  final ScrollController _scrollController = ScrollController();

  List<LinkItem> shortLinks = [];
  Set<String> selectedIds = {};
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
    loadShortLinks(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Поиск (описание или ключ)',
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
                      itemCount: shortLinks.length,
                      itemBuilder: (context, index) {
                        final link = shortLinks[index];
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
                            title: Text(displayText),
                            subtitle: Text(link.shortKey),
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
        if (hasMore && !loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                page++;
                loadShortLinks();
              },
              child: const Text('Загрузить ещё'),
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
