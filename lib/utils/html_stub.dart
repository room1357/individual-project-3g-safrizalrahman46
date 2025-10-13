// lib/utils/html_stub.dart

// Versi lebih lengkap untuk menggantikan dart:html di mobile
class AnchorElement {
  String? href;
  String? download; // ✅ Properti untuk nama file

  AnchorElement({this.href});

  // ✅ Metode palsu agar tidak error
  void setAttribute(String name, String value) {
    if (name == 'download') {
      download = value;
    }
  }

  void click() {} // Tidak melakukan apa-apa di mobile
}

class Blob {
  Blob(List<dynamic> blobParts, [String? type]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class HttpRequest {
  static Future<dynamic> request(String url, {String? responseType}) {
    throw UnimplementedError('HttpRequest.request is not available on this platform.');
  }
}