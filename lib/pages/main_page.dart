import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatelessWidget {
  final List<Map<String, String>> shortLinks = [
    {
      'description': 'Мой сайт',
      'shortKey': 'abc123',
      'longLink': 'http://httpforever.com/'
    },
    {
      'description': 'Блог',
      'shortKey': 'xyz789',
      'longLink': 'https://www.desmos.com/?lang=ru'
    },
  ];

  MainPage({super.key});

  void copyToClipboard(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ссылка скопирована!')),
    );
  }

  void openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ваши короткие ссылки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('+ Создать короткую ссылку'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: shortLinks.length,
                itemBuilder: (context, index) {
                  final link = shortLinks[index];
                  final shortUrl = 'https://short.ly/${link['shortKey']}';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () {},
                        child: Text(
                          link['description'] ?? link['shortKey']!,
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
                                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => copyToClipboard(context, shortUrl),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => openLink(link['longLink']!),
                            child: RichText(
                              text: TextSpan(
                                text: 'Целевая ссылка: ',
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: link['longLink'],
                                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
