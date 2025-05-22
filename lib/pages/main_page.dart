import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'short_link_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> shortLinks = [];
  bool loading = false;
  String sortBy = 'updatedAt';
  String sortDirection = 'desc';
  String searchQuery = '';
  int page = 1;
  int limit = 5;
  int totalPages = 1;

  final ScrollController _scrollController = ScrollController();

  final _dio = DioClient().dio;

  @override
  void initState() {
    super.initState();
    loadShortLinks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadShortLinks() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await _dio.get(
        '/api/v1/short-links?sortBy=$sortBy&sortDirection=$sortDirection&search=$searchQuery&page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          if (page == 1) {
            shortLinks = List<Map<String, dynamic>>.from(data['data']);
          } else {
            shortLinks.addAll(List<Map<String, dynamic>>.from(data['data']));
          }
          totalPages = data['totalPages'];
        });
      } else {
        print(response.data);
        throw Exception('Failed to load short links');
      }
    } catch (e) {
      print('Error loading short links: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void copyToClipboard(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Короткая ссылка скопирована')),
    );
  }

  void openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e) {
        return;
      }
    }
  }

  void openShortLinkPage(String linkId, String shortKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShortLinkPage(linkId: linkId, shortKey: shortKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Короткие ссылки',
        showReportsButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create');
              },
              child: const Text(
                'Создать короткую ссылку',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: "Поиск (введите часть описания или ключа)",
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  page = 1; // Сбросить страницу при новом поиске
                });
                loadShortLinks();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Сортировка:",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16, // Указываем размер шрифта
                  ),
                ),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: "updatedAt",
                      child: Text(
                        "Дата изменения",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "createdAt",
                      child: Text(
                        "Дата создания",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "description",
                      child: Text(
                        "Описание",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                      page = 1; // Сбросить страницу при изменении сортировки
                    });

                    loadShortLinks();
                  },
                ),

                IconButton(
                  icon: Icon(
                    sortDirection == 'asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      sortDirection = sortDirection == 'asc' ? 'desc' : 'asc';
                      page =
                          1; // Сбросить страницу при изменении направления сортировки
                    });

                    loadShortLinks();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: shortLinks.length + 1,
                    itemBuilder: (context, index) {
                      if (index == shortLinks.length) {
                        if (page < totalPages) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Center(
                              child: SizedBox(
                                width:
                                    200, // Фиксированная ширина как у кнопки создания
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      page++;
                                    });
                                    loadShortLinks();
                                  },
                                  child: const Text(
                                    'Загрузить ещё',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink(); // или пустое место, если больше страниц нет
                        }
                      }

                      final link = shortLinks[index];

                      final shortUrl =
                          '${dotenv.env['SHORT_LINKS_WEB_APP_URL']}/${link['shortKey']}';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: GestureDetector(
                            onTap:
                                () => openShortLinkPage(
                                  link['id'],
                                  link['shortKey'],
                                ),
                            child: Text(
                              link['description'].toString().isNotEmpty
                                  ? link['description']
                                  : link['shortKey'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16, // Указываем размер шрифта
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => openLink(shortUrl),
                                      child: Text(
                                        shortUrl,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center, // Center vertically
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed:
                                            () => copyToClipboard(
                                              context,
                                              shortUrl,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => openLink(link['longLink']!),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        link['longLink']!,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                        maxLines: 1, // Limit to 1 line
                                        overflow:
                                            TextOverflow
                                                .ellipsis, // Add ellipsis if text overflows
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Дата создания: ${dateFormat.format(DateTime.parse(link['createdAt']).toLocal())}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "Дата изменения: ${dateFormat.format(DateTime.parse(link['updatedAt']).toLocal())}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                onRefresh: () async {
                  setState(() {
                    page = 1; // Сбросить страницу при обновлении
                  });

                  await loadShortLinks();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
