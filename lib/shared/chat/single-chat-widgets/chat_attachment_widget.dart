
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/shared/chat/chat-share/custom_lightbox.dart';
import 'package:health_care/shared/chat/chat_helpers/get_file_icon.dart';
import 'package:health_care/shared/chat/chat_helpers/save_bytes_to_file.dart';
import 'package:health_care/src/utils/encrupt_decrypt.dart';

class ChatAttachmentWidget extends StatefulWidget {
  final MessageType message;
  final String userId;
  const ChatAttachmentWidget({
    super.key,
    required this.message,
    required this.userId,
  });

  @override
  State<ChatAttachmentWidget> createState() => _ChatAttachmentWidgetState();
}

class _ChatAttachmentWidgetState extends State<ChatAttachmentWidget> {
  late String messageText = "";
  final Map<String, Uint8List> _loadedImages = {};
  final Set<String> _loadingInProgress = {};
  @override
  void initState() {
    super.initState();
    final msg = widget.message.message;
    if (msg != null && msg.isNotEmpty) {
      messageText = decrypt(msg);
    }
    _maybeLoadImages();
  }

void _maybeLoadImages() {
  for (final attachment in widget.message.attachment) {
    if (!attachment.isImage) continue;

    final alreadyCached = AttachmentCache.get(attachment.id);
    if (alreadyCached != null) {
      _loadedImages[attachment.id] = alreadyCached;
      continue;
    }

    if (_loadingInProgress.contains(attachment.id)) continue;

    _loadingInProgress.add(attachment.id);

    AttachmentCache.fetch(attachment.id, widget.userId).then((bytes) {
      if (bytes != null && mounted) {
        _loadedImages[attachment.id] = bytes;
        setState(() {});
      }
    }).whenComplete(() {
      _loadingInProgress.remove(attachment.id);
    });
  }
}

  @override
  void didUpdateWidget(covariant ChatAttachmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message != widget.message) {
      final newIds = widget.message.attachment.map((e) => e.id).toSet();
      _loadedImages.removeWhere((id, _) => !newIds.contains(id));
      messageText = '';
      final msg = widget.message.message;
      if (msg != null && msg.isNotEmpty) {
        messageText = decrypt(msg);
      }
      _maybeLoadImages();
    }
  }

  @override
  void dispose() {
    _loadedImages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    final message = widget.message;
    final attachments = message.attachment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: attachments.asMap().entries.map((entry) {
            final attach = entry.value;
            final isImage = attach.isImage;
            final String fileType = attach.type;
            final String fileName = attach.name;
            final imageBytes = _loadedImages[attach.id];
            return InkWell(
              key: ValueKey(attach.id),
              onTap: () async {
                if (isImage) {
                  final imageAttachments = attachments.where((e) => e.isImage).toList();
                  final imageIndex = imageAttachments.indexOf(attach);
                  showDialog(
                    context: context,
                    builder: (_) => CustomLightbox(
                      initialIndex: imageIndex,
                      memoryImages: imageAttachments.map((e) => _loadedImages[e.id]).toList(),
                      fallbackAssets: imageAttachments.map((e) => e.src).toList(),
                    ),
                  );
                } else {
                  final fileBytes = await getChatFile(attach.id, widget.userId); // ✅ Load file for download
                  if (fileBytes != null && context.mounted) {
                    await saveBytesToFile(
                      bytes: fileBytes,
                      fileName: fileName,
                      context: context,
                      onDone: (path) {
                        showErrorSnackBar(context, context.tr('savedToDownload', args: [path]));
                      },
                    );
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    isImage
                        ? imageBytes != null
                            ? Image.memory(imageBytes, width: 80, height: 80, fit: BoxFit.cover)
                            : Image.asset(getFileIcon(fileType), width: 80, height: 80, fit: BoxFit.cover)
                        : Image.asset(getFileIcon(fileType), width: 80, height: 80, fit: BoxFit.cover),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black.withAlpha(150),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          fileName,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (messageText.isNotEmpty) ...[
          Text(
            messageText,
            style: TextStyle(color: textColor),
          )
        ]
      ],
    );
  }
}
class AttachmentCache {
  static final _mem = <String, Uint8List>{};

  static Uint8List? get(String id) => _mem[id];

  static Future<Uint8List?> fetch(String id, String userId) async {
    return _mem[id] ??= (await getChatFile(id, userId))!;
  }
}