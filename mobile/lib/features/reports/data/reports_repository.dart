import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final reportsRepositoryProvider = Provider((ref) {
  return ReportsRepository(ref.watch(apiClientProvider));
});

class ReportsRepository {
  final Dio _dio;

  ReportsRepository(this._dio);

  Future<String?> exportMatchReport(String jobId) async {
    try {
      final response = await _dio.post('/report/match/$jobId');
      if (response.statusCode == 200) {
        return response.data['report_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
