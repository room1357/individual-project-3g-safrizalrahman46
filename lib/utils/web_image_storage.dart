import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveProfileImageWeb(String userId, Uint8List imageBytes) async {
  final prefs = await SharedPreferences.getInstance();
  final base64Image = base64Encode(imageBytes);
  await prefs.setString('user_image_$userId', base64Image);
}

Future<Uint8List?> loadProfileImageWeb(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final base64Image = prefs.getString('user_image_$userId');
  if (base64Image != null) {
    return base64Decode(base64Image);
  }
  return null;
}
