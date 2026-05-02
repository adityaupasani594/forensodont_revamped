import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/network/api_client.dart';

final matchingRepositoryProvider = Provider((ref) {
  return MatchingRepository(ref.watch(apiClientProvider));
});

class MatchingRepository {
  final Dio _dio;

  MatchingRepository(this._dio);

  Future<Map<String, dynamic>?> startMatch(String caseId, String opgImageId, Map<String, dynamic> filters) async {
    try {
      final response = await _dio.post('/match/', data: {
        'case_id': caseId,
        'opg_image_id': opgImageId,
        'filters': filters,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<dynamic> getProgressStream(String jobId) {
    // In production, use wss and the real host
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000/api/v1/match/progress/$jobId'),
    );
    return channel.stream.map((event) => jsonDecode(event));
  }

  Future<List<dynamic>> getResults(String jobId) async {
    try {
      final response = await _dio.get('/match/$jobId/results');
      if (response.statusCode == 200) {
        return response.data['candidates'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCandidateDetails(String jobId, String candidateId) async {
    try {
      final response = await _dio.get('/match/$jobId/results/$candidateId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}



