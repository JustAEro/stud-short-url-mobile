import 'package:dio/dio.dart';
import 'package:stud_short_url_mobile/clients/dio_client.dart';
import 'package:stud_short_url_mobile/dto/paginated_links.dart';

class LinkService {
  final Dio _dio = DioClient().dio;

  Future<PaginatedLinks> fetchLinks({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortField,
    bool ascending = true,
  }) async {
    final response = await _dio.get(
      '/api/v1/short-links',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (searchQuery != null) 'search': searchQuery,
        if (sortField != null) 'sortBy': sortField,
        'sortDirection': ascending ? 'asc' : 'desc',
      },
    );

    return PaginatedLinks.fromJson(response.data);
  }
}
