import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stud_short_url_mobile/widgets/authenticated_app_bar.dart';

class ShareShortLinkPage extends StatefulWidget {
  final String shortKey;

  const ShareShortLinkPage({super.key, required this.shortKey});

  @override
  State<ShareShortLinkPage> createState() => _ShareShortLinkPageState();
}

class _ShareShortLinkPageState extends State<ShareShortLinkPage> {
  late final String shortUrl;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    shortUrl = '${dotenv.env['SHORT_LINKS_WEB_APP_URL']}/${widget.shortKey}';
  }

  Future<void> _shareQrCode() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: shortUrl);
    } catch (e) {
      debugPrint("Ошибка при создании QR-кода: $e");
    }
  }

  void _showFullScreenQr() async {
    await showDialog(
      context: context,
      builder:
          (_) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black,
              child: Center(
                child: QrImageView(
                  data: shortUrl,
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width * 0.8,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Поделиться ссылкой'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _showFullScreenQr,
                  onLongPress: _shareQrCode,
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24), // внешний отступ
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: Center(
                          child: QrImageView(
                            data: shortUrl,
                            version: QrVersions.auto,
                            size: 250.0, // важно, чтобы было меньше SizedBox
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  shortUrl,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: shortUrl));
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Ссылка скопирована')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Скопировать ссылку"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
