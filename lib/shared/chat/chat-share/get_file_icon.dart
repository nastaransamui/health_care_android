String getFileIcon(String fileType) {
  fileType = fileType.toLowerCase();

  if (fileType.contains("pdf")) {
    return 'assets/icon/pdf-icon.png';
  } else if (fileType.contains("word")) {
    return 'assets/icon/word-icon.png';
  } else if (fileType.contains("excel")) {
    return 'assets/icon/excel-icon.png';
  } else if (fileType.contains("powerpoint")) {
    return 'assets/icon/ppt-icon.png';
  } else if (fileType.contains("text")) {
    return 'assets/icon/txt-icon.png';
  } else if (fileType.contains("zip") || fileType.contains("rar") || fileType.contains("7z")) {
    return 'assets/icon/zip-icon.png';
  }

  return 'assets/icon/image-icon.png'; // Default icon
}
