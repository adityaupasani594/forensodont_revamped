import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/cases_repository.dart';

final casesProvider = FutureProvider.autoDispose<List<CaseModel>>((ref) async {
  return ref.watch(casesRepositoryProvider).getCases();
});
