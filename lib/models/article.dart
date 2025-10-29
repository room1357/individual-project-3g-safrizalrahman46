class Article {
  final String title;
  final String? source;
  final String? publishedAt;
  final String? urlToImage;

  Article({
    required this.title,
    this.source,
    this.publishedAt,
    this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Tanpa Judul',
      source: json['source']?['name'] ?? 'Tidak diketahui',
      publishedAt: json['publishedAt'] ?? '',
      urlToImage: json['urlToImage'],
    );
  }
}
