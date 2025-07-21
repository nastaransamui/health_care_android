import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CustomLightbox extends StatelessWidget {
  final int initialIndex;
  final List<Uint8List?> memoryImages;
  final List<String?> fallbackAssets;

  const CustomLightbox({
    super.key,
    required this.initialIndex,
    required this.memoryImages,
    required this.fallbackAssets,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);
    final ThemeData theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.cardTheme.color,
      insetPadding: EdgeInsets.zero,
      child: PageView.builder(
        controller: controller,
        itemCount: memoryImages.length,
        itemBuilder: (context, index) {
          final imageBytes = memoryImages[index];
          final fallback = fallbackAssets[index];

          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: theme.cardTheme.color),
              imageProvider: imageBytes != null
                  ? MemoryImage(imageBytes)
                  : AssetImage(
                      fallback ?? 'assets/icon/image-icon.png',
                    ) as ImageProvider,
            ),
          );
        },
      ),
    );
  }
}
