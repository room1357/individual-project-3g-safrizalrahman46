// // lib/utils/web_image_helper.dart
// import 'dart:convert';
// import 'dart:html' as html;
// import 'dart:typed_data';

// Future<String?> imageFileToBase64Web(String imageUrl) async {
//   try {
//     final request = await html.HttpRequest.request(
//       imageUrl,
//       responseType: 'arraybuffer',
//     );
//     final bytes = Uint8List.view(request.response);
//     return 'data:image/png;base64,${base64Encode(bytes)}';
//   } catch (e) {
//     print('⚠️ Error convert Web image to Base64: $e');
//     return null;
//   }
// }
import 'html_stub.dart' if (dart.library.html) 'dart:html' as html;

export 'web_image_helper_stub.dart'
    if (dart.library.html) 'web_image_helper_web.dart';
