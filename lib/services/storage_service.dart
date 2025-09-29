// Untuk penyimpanan data (sementara dummy, nanti bisa pakai SharedPreferences/DB)
class StorageService {
  Future<void> saveData(String key, String value) async {
    // implementasi simpan data
  }

  Future<String?> loadData(String key) async {
    // implementasi load data
    return null;
  }
}
