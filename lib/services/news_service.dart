import '../models/article.dart';
import '../client/rest_client.dart';

class NewsService {
  final RestClient restClient;

  NewsService(this.restClient);

  Future<List<Article>> fetchTopHeadlines() async {
    final response = await restClient.fetchNews(query: {'country': 'id'});
    final articles = (response['articles'] as List)
        .map((json) => Article.fromJson(json))
        .toList();
    return articles;
  }
}
