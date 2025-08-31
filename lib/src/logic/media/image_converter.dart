import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Utility class for converting images between File and Base64 formats
class ImageConverter {
  /// Converts a File to Base64 string
  static Future<String> fileToBase64(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Error converting file to Base64: $e');
    }
  }

  /// Converts a Base64 string to Uint8List bytes
  static Uint8List base64ToBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      throw Exception('Error converting Base64 to bytes: $e');
    }
  }

  /// Checks if a string is a valid Base64 encoded image
  static bool isValidBase64Image(String base64String) {
    if (base64String.isEmpty) return false;

    try {
      final bytes = base64Decode(base64String);
      // Check for common image file signatures
      if (bytes.length < 4) return false;

      // JPEG signature
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;

      // PNG signature
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return true;
      }

      // GIF signature
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;

      // WebP signature
      if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gets the estimated size in KB of a Base64 encoded image
  static double getBase64ImageSizeKB(String base64String) {
    if (base64String.isEmpty) return 0;
    // Base64 encoding increases size by ~33%, so we calculate the original size
    final bytes = (base64String.length * 3) / 4;
    return bytes / 1024;
  }
}
