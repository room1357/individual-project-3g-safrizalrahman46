import 'package:flutter/foundation.dart'
    show kIsWeb;

import 'app_directory_mobile.dart'
    if (dart.library.io) 'app_directory_mobile.dart'
    if (dart.library.html) 'app_directory_web.dart';

/// ✅ Abstraksi aman dipanggil dari mana pun
Future<String?> getAppDocumentsDirectoryPath() async {
  return await getAppDocumentsDirectoryPathImpl();
}
