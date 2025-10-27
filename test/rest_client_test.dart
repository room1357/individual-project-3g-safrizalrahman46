// Lokasi: test/rest_client_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// GANTI 'NAMA_PROYEK_ANDA' dengan nama dari pubspec.yaml Anda
import 'package:pemrograman_mobile/rest_client.dart';

// --- (Mock client setup dari GitHub) ---
MockClient _mockClient(String body, int statusCode) {
  return MockClient(
    (request) async => http.Response(body, statusCode),
  );
}

void main() {
  group('RestClient', () {
    test('fetchPosts returns list of posts', () async {
      final mock = _mockClient(
        '[{"id": 1, "userId": 1, "title": "foo", "body": "bar"}]',
        200,
      );
      // Error 'RestClient' akan hilang
      final client = RestClient(httpClient: mock); 
      final posts = await client.fetchPosts();

      expect(posts, isA<List<Post>>());
      expect(posts.first.id, 1);
      expect(posts.first.title, 'foo');
    });

    test('fetchPost returns a post', () async {
      final mock = _mockClient(
        '{"id": 1, "userId": 1, "title": "foo", "body": "bar"}',
        200,
      );
      // Error 'RestClient' akan hilang
      final client = RestClient(httpClient: mock);
      final post = await client.fetchPost(1);

      expect(post, isA<Post>());
      expect(post.id, 1);
      expect(post.title, 'foo');
    });

    // ... (Sisa tes lainnya) ...
  });
}