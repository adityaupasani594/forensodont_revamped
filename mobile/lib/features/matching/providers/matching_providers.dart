import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/matching_repository.dart';

final matchingResultsProvider = FutureProvider.family<List<dynamic>, String>((ref, jobId) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getResults(jobId);
});

final candidateDetailsProvider = FutureProvider.family<Map<String, dynamic>?, ({String jobId, String candidateId})>((ref, arg) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getCandidateDetails(arg.jobId, arg.candidateId);
});

