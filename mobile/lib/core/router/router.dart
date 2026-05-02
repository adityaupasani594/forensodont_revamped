import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/cases/presentation/cases_screen.dart';
import '../../features/cases/presentation/new_case_screen.dart';
import '../../features/matching/presentation/matching_progress_screen.dart';
import '../../features/matching/presentation/results_screen.dart';
import '../../features/matching/presentation/candidate_detail_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/cases',
      builder: (context, state) => const CasesScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const NewCaseScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            // For now just returning a placeholder or the detail screen
            return const Placeholder(); 
          },
          routes: [
            GoRoute(
              path: 'matching/:jobId',
              builder: (context, state) => MatchingProgressScreen(
                caseId: state.pathParameters['id']!,
                jobId: state.pathParameters['jobId']!,
              ),
            ),

            GoRoute(
              path: 'results/:jobId',
              builder: (context, state) => ResultsScreen(
                caseId: state.pathParameters['id']!,
                jobId: state.pathParameters['jobId']!,
              ),
            ),

            GoRoute(
              path: 'results/:jobId/candidates/:candidateId',
              builder: (context, state) => CandidateDetailScreen(
                caseId: state.pathParameters['id']!,
                jobId: state.pathParameters['jobId']!,
                candidateId: state.pathParameters['candidateId']!,
              ),
            ),

          ],
        ),
      ],
    ),
  ],
);
