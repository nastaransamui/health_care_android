
import 'package:encrypt/encrypt.dart' as encrypttext;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Must be 32 characters for AES-256
String encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? 'your-32-character-key';

final key = encrypttext.Key.fromUtf8(encryptionKey);
const ivLength = 16;

String encrypt(String plainText) {
  final iv = encrypttext.IV.fromSecureRandom(ivLength);
  final encrypter = encrypttext.Encrypter(encrypttext.AES(key, mode: encrypttext.AESMode.cbc));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  // Return IV and encrypted text as hex, separated by :
  return '${iv.base16}:${encrypted.base16}';
}

String decrypt(String encryptedData) {
  final parts = encryptedData.split(':');
  if (parts.length != 2) throw ArgumentError('Invalid encrypted data format');
  final iv = encrypttext.IV.fromBase16(parts[0]);
  final encrypted = encrypttext.Encrypted.fromBase16(parts[1]);
  final encrypter = encrypttext.Encrypter(encrypttext.AES(key, mode: encrypttext.AESMode.cbc));
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}
