import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final casesRepositoryProvider = Provider((ref) {
  return CasesRepository(ref.watch(apiClientProvider));
});

class CaseModel {
  final String id;
  final String referenceNumber;
  final String status;
  final String? incidentName;
  final DateTime createdAt;

  CaseModel({
    required this.id,
    required this.referenceNumber,
    required this.status,
    this.incidentName,
    required this.createdAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'],
      referenceNumber: json['reference_number'],
      status: json['status'],
      incidentName: json['incident_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CasesRepository {
  final Dio _dio;

  CasesRepository(this._dio);

  Future<List<CaseModel>> getCases() async {
    try {
      final response = await _dio.get('/cases/');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => CaseModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<CaseModel?> createCase(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/cases/', data: data);
      if (response.statusCode == 200) {
        return CaseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> promoteToUnidentified(String caseId) async {
    try {
      final response = await _dio.post('/cases/$caseId/promote-unidentified');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final casesProvider = FutureProvider<List<CaseModel>>((ref) async {
  final repository = ref.watch(casesRepositoryProvider);
  return repository.getCases();
});



