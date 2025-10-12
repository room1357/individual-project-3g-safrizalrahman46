import 'package:path_provider/path_provider.dart';

/// ✅ Untuk Android/iOS/Desktop
Future<String?> getAppDocumentsDirectoryPathImpl() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}
