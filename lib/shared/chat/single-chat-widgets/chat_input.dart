import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/src/features/loading_screen.dart';
import 'package:health_care/shared/chat/chat_helpers/get_file_icon.dart';
import 'package:health_care/src/utils/play_sound.dart';

import 'package:health_care/stream_socket.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController chatInputController;
  final ChatDataType currentRoom;
  final String currentUserId;
  final FocusNode focusNode;
  final ValueChanged<bool> taggleEditMessage;
  final bool isEditMessage;
  final Set<int> showDeleteIndices;
  final ValueChanged<int> bubbleChatLongPress;
  final int editMessageTime;
  const ChatInput({
    super.key,
    required this.chatInputController,
    required this.currentRoom,
    required this.currentUserId,
    required this.focusNode,
    required this.isEditMessage,
    required this.taggleEditMessage,
    required this.showDeleteIndices,
    required this.bubbleChatLongPress,
    required this.editMessageTime,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final ImagePicker _attachmentImagePicker = ImagePicker();
  List<Map<String, dynamic>> attachmentFilesList = [];


  @override
  void dispose() {
    attachmentFilesList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withAlpha(255),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isEditMessage)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.canvasColor,
                    border: BoxBorder.all(color: theme.primaryColorLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${widget.chatInputController.text} ${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(widget.editMessageTime))}",
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (attachmentFilesList.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.canvasColor,
                    border: BoxBorder.all(color: theme.primaryColorLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: attachmentFilesList.map(
                      (image) {
                        var index = attachmentFilesList.indexOf(image);
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SizedBox(
                                height: 60,
                                width: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: image['isImage']
                                      ? Image.file(
                                          File(image['src']),
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.asset(
                                          getFileIcon(image['type']),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: IconButton(
                                color: Colors.pinkAccent.shade400,
                                onPressed: () {
                                  setState(() {
                                    attachmentFilesList.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120, // roughly 5 lines depending on font
                      ),
                      child: Scrollbar(
                        child: TextField(
                          controller: widget.chatInputController,
                          focusNode: widget.focusNode,
                          enableSuggestions: true,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          onEditingComplete: () {
                            widget.focusNode.requestFocus();
                          },
                          decoration: InputDecoration(
                            hintText: context.tr('typeSomething'),
                            hintStyle: TextStyle(color: textColor),
                            isDense: true,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            prefixIcon: GestureDetector(
                              onTap: () {
                                if (widget.isEditMessage) {
                                  int index = widget.showDeleteIndices.first;
                                  widget.bubbleChatLongPress(index);
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: ((builder) => bottomSheet()),
                                  );
                                }
                              },
                              child: Icon(widget.isEditMessage ? Icons.cancel : Icons.upload_file,
                                  color: widget.isEditMessage ? Colors.pink : theme.iconTheme.color, size: 24),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                // 1. Grab trimmed message
                                final text = widget.chatInputController.text.trim();
                                if (text.isEmpty && attachmentFilesList.isEmpty) return;

                                // 2. Emit your socket message
                                final String receiverId = widget.currentRoom.createrData.userId == widget.currentUserId
                                    ? widget.currentRoom.receiverData.userId
                                    : widget.currentRoom.createrData.userId;

                                List<Map<String, dynamic>>? attachmentFiles = [];

                                if (attachmentFilesList.isNotEmpty) {
                                  for (var i = 0; i < attachmentFilesList.length; i++) {
                                    var element = attachmentFilesList[i];
                                    final fileFromImage = element['attachmentFile'];
                                    List<int> fileBytes = await fileFromImage.readAsBytes();
                                    Uint8List fileUint8List = Uint8List.fromList(fileBytes);
                                    attachmentFiles.add({
                                      'attachFile': fileUint8List,
                                      'attachFileName': element['name'],
                                      'attachFileExtentionNoDot': element['attachmentExtentionNoDot'],
                                      "attachFileType": element['type']
                                    });
                                  }
                                }

                                if (!widget.isEditMessage) {
                                  Map<String, dynamic> messageData = {
                                    "senderId": widget.currentUserId,
                                    "receiverId": receiverId,
                                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                                    "message": text.isEmpty ? null : text,
                                    "read": false,
                                    "attachment": [],
                                    "roomId": widget.currentRoom.roomId,
                                    "attachmentFiles": attachmentFiles,
                                    "calls": []
                                  };
                                  socket.emit('sendMessage', messageData);
                                  playSendMessageSound();
                                  attachmentFiles.clear();
                                  setState(() {
                                    attachmentFilesList.clear();
                                  });
                                  // 4. Manually keep focus
                                  if (text.isNotEmpty) {
                                    // 3. Clear without dropping focus
                                    widget.chatInputController
                                      ..text = ''
                                      ..selection = const TextSelection.collapsed(offset: 0);
                                    Future.microtask(() {
                                      if (mounted && !widget.focusNode.hasFocus) {
                                        widget.focusNode.requestFocus();
                                      }
                                    });
                                  }
                                } else {
                                  Map<String, dynamic> messageData = {
                                    "senderId": widget.currentUserId,
                                    "receiverId": receiverId,
                                    "timestamp": widget.editMessageTime,
                                    "message": text,
                                    "read": false,
                                    "attachment": [],
                                    "roomId": widget.currentRoom.roomId,
                                    "attachmentFiles": attachmentFiles,
                                    "calls": []
                                  };

                                  socket.emit('editMessage', messageData);
                                  int index = widget.showDeleteIndices.first;
                                  widget.bubbleChatLongPress(index);
                                }
                              },
                              child: Icon(
                                widget.isEditMessage ? Icons.edit : Icons.send,
                                color: theme.iconTheme.color,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 150.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            context.tr('chooseChatFiles'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            IconButton(
              icon: const Icon(Icons.camera),
              onPressed: () {
                takePhoto();
              },
              // label: Text("Camera"),
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                fileSelectorGallery();
              },
              // label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Future fileSelectorGallery() async {
    if (mounted) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      ).whenComplete(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
        });
      });
    }
    FilePickerResult? files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        // Images
        'jpg',
        'jpeg',
        'png',

        // Word Documents
        'doc',
        'docx',

        // PDF
        'pdf',

        // Plain Text
        'txt',

        // Excel
        'xls',
        'xlsx',

        // PowerPoint
        'ppt',
        'pptx',

        // OpenDocument formats
        'odt',
        'ods',
        'odp',

        // Archives
        'zip',
        'rar',
        '7z',
      ],
    );
    int totalAttachmentFiles = attachmentFilesList.length;
    if (files != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      for (var i = 0; i < files.files.length; i++) {
        var element = files.files[i];
        if (element.size < 2000000) {
          totalAttachmentFiles++;
          if (totalAttachmentFiles <= 5) {
            String extension = element.extension?.toLowerCase() ?? element.name.split('.').last.toLowerCase();
            String fileType = getMimeType(extension);
            setState(() {
              attachmentFilesList = [
                ...attachmentFilesList,
                {
                  "attachmentFile": File(element.path!),
                  "attachmentExtentionNoDot": element.name.split('.').last,
                  "name": element.name,
                  "src": element.path,
                  "isImage": fileType == 'image',
                  "type": fileType,
                  "id": '',
                }
              ];
            });
          } else {
            if (mounted) {
              showCustomToast(context, 'max5File');
            }
          }
        } else {
          if (mounted) {
            showCustomToast(context, 'imageSizeExtend');
          }
        }
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }

  void takePhoto() async {
    if (mounted) {
      showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        showDragHandle: false,
        useSafeArea: true,
        context: context,
        builder: (context) => const LoadingScreen(),
      ).whenComplete(() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).maybePop();
        });
      });
    }
    final pickedFile = await _attachmentImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
      var size = await File(pickedFile.path).length();
      if (size < 2000000) {
        setState(() {
          attachmentFilesList = [
            ...attachmentFilesList,
            {
              "attachmentFile": File(pickedFile.path),
              "attachmentExtentionNoDot": pickedFile.name.split('.').last,
              "name": pickedFile.name,
              "src": pickedFile.path,
              "isImage": true,
              "type": 'image',
              "id": '',
            }
          ];
        });
      } else {
        if (mounted) {
          showCustomToast(context, 'imageSizeExtend');
        }
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).maybePop();
      });
    }
  }
}

String getMimeType(String ext) {
  switch (ext) {
    case 'jpg':
    case 'jpeg':
    case 'png':
      return 'image';
    case 'pdf':
      return 'pdf';
    case 'doc':
    case 'docx':
      return 'word';
    case 'xls':
    case 'xlsx':
      return 'excel';
    case 'ppt':
    case 'pptx':
      return 'powerpoint';
    case 'txt':
      return 'text';
    case 'zip':
    case 'rar':
    case '7z':
      return 'archive';
    default:
      return 'unknown';
  }
}

void showCustomToast(BuildContext context, String msg) {
  final ThemeData theme = Theme.of(context);
  final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  BotToast.showCustomText(
    toastBuilder: (cancelFunc) => Card(
      color: theme.cardColor.withAlpha(255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                context.tr(msg),
                style: TextStyle(color: textColor),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: theme.primaryColor),
              onPressed: cancelFunc,
            )
          ],
        ),
      ),
    ),
    duration: const Duration(days: 1), // stays until closed
    onlyOne: true,
    crossPage: true,
    align: Alignment.topCenter,
  );
}
