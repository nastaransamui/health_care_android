

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile> getImageXFileByUrl(String url) async {
    var file = await DefaultCacheManager().getSingleFile(url);
    XFile result = XFile(file.path);
    return result;
  }