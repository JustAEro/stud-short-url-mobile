import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, dynamic>> allShortLinks = [
    {
      'description': 'Мой сайт',
      'shortKey': 'abc123',
      'longLink': 'https://example.com/my-site',
      'createdAt': DateTime.now().subtract(Duration(days: 1)),
      'updatedAt': DateTime.now().subtract(Duration(hours: 1)),
    },
    {
      'description': 'Блог1',
      'shortKey': 'xyz789',
      'longLink':
          'https://www.google.com/search?q=sharedpreferences+vs+datastore&sca_esv=cb2bd471e7c0d922&sxsrf=AHTn8zpZUvM6V1AyaRQSbNTEw7qSlyaOvQ%3A1742158228685&ei=lDnXZ7K7KbWK9u8P3oTV2AU&oq=SharedPreferences+%D0%BC%D1%8B&gs_lp=Egxnd3Mtd2l6LXNlcnAiFlNoYXJlZFByZWZlcmVuY2VzINC80YsqAggAMgcQABiABBgNMgcQABiABBgNMgYQABgNGB4yBhAAGA0YHjIGEAAYDRgeMgYQABgNGB4yBhAAGA0YHjIGEAAYDRgeMgYQABgNGB4yBhAAGA0YHkjqEVCPB1iOC3ABeAGQAQCYAY8BoAHbAqoBAzEuMrgBAcgBAPgBAZgCBKAC9wLCAgoQABiwAxjWBBhHwgINEAAYgAQYsAMYQxiKBcICGRAuGIAEGLADGNEDGEMYxwEYyAMYigXYAQHCAgUQABiABMICChAAGIAEGEMYigXCAgUQIRigAZgDAIgGAZAGC7oGBAgBGAiSBwMxLjOgB8MR&sclient=gws-wiz-serp',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог2',
      'shortKey': 'xyz7893',
      'longLink': 'https://example.com/blog1',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог3',
      'shortKey': 'xyz7894',
      'longLink': 'https://example.com/blog2',
      'createdAt': DateTime.now().subtract(Duration(days: 2)),
      'updatedAt': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'description': 'Блог4',
      'shortKey': 'xyz7895',
      'longLink': 'https://example.com/blog3',
      'createdAt': DateTime.now().subtract(Duration(days: 3)),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог5',
      'shortKey': 'xyz7896',
      'longLink': 'https://example.com/blog4',
      'createdAt': DateTime.now().subtract(Duration(days: 4)),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог6',
      'shortKey': 'xyz7897',
      'longLink': 'https://example.com/blog5',
      'createdAt': DateTime.now().subtract(Duration(days: 5)),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог7',
      'shortKey': 'xyz7898',
      'longLink': 'https://example.com/blog6',
      'createdAt': DateTime.now().subtract(Duration(days: 6)),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог8',
      'shortKey': 'xyz7899',
      'longLink': 'https://example.com/blog7',
      'createdAt': DateTime.now().subtract(Duration(days: 7)),
      'updatedAt': DateTime.now(),
    },
    {
      'description': 'Блог9',
      'shortKey': 'xyz7900',
      'longLink': 'https://example.com/blog8',
      'createdAt': DateTime.now().subtract(Duration(days: 8)),
      'updatedAt': DateTime.now(),
    },
  ];

  List<Map<String, dynamic>> displayedLinks = [];
  String searchQuery = "";
  String sortBy = "description";
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    // Изначально отображаем 5 ссылок
    displayedLinks = allShortLinks.take(5).toList();
  }

  void loadMoreLinks() {
    setState(() {
      // Загружаем следующие 5 ссылок, если они есть
      int nextIndex = displayedLinks.length;
      if (nextIndex < allShortLinks.length) {
        displayedLinks.addAll(
          allShortLinks.getRange(
            nextIndex,
            nextIndex + 5 <= allShortLinks.length
                ? nextIndex + 5
                : allShortLinks.length,
          ),
        );
      }
    });
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
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  List<Map<String, dynamic>> getFilteredAndSortedLinks() {
    List<Map<String, dynamic>> filteredLinks =
        displayedLinks
            .where(
              (link) =>
                  link['description']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  link['shortKey']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    filteredLinks.sort((a, b) {
      int comparison;
      if (sortBy == "description") {
        comparison = (a['description'] ?? a['shortKey']).compareTo(
          b['description'] ?? b['shortKey'],
        );
      } else if (sortBy == "shortKey") {
        comparison = a['shortKey'].compareTo(b['shortKey']);
      } else {
        comparison = a['createdAt'].compareTo(b['createdAt']);
      }
      return ascending ? comparison : -comparison;
    });

    return filteredLinks;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши короткие ссылки'),
        centerTitle: true,
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
                });
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
                      value: "description",
                      child: Text(
                        "Описание",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Указываем размер шрифта
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "shortKey",
                      child: Text(
                        "Короткий ключ",
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
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                ),

                IconButton(
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: getFilteredAndSortedLinks().length,
                itemBuilder: (context, index) {
                  final link = getFilteredAndSortedLinks()[index];
                  final shortUrl = 'https://short.ly/${link['shortKey']}';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () {},
                        child: Text(link['description'] ?? link['shortKey']),
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
                                      decoration: TextDecoration.underline,
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
                                        () =>
                                            copyToClipboard(context, shortUrl),
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
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Text(
                                    link['longLink']!,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
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
                            "Дата создания: ${dateFormat.format(link['createdAt'])}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Дата изменения: ${dateFormat.format(link['updatedAt'])}",
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
            if (displayedLinks.length < allShortLinks.length)
              ElevatedButton(
                onPressed: loadMoreLinks,
                child: const Text(
                  'Загрузить ещё',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
