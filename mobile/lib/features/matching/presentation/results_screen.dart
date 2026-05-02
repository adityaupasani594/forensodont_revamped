import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/matching_providers.dart';
import '../../cases/data/cases_repository.dart';
import '../../reports/data/reports_repository.dart';
import 'widgets/confidence_breakdown_card.dart';


class ResultsScreen extends ConsumerWidget {
  final String caseId;
  final String jobId;
  const ResultsScreen({super.key, required this.caseId, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final url = await ref.read(reportsRepositoryProvider).exportMatchReport(jobId);
              if (context.mounted) {
                if (url != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report generated: $url')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to generate report')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ref.watch(matchingResultsProvider(jobId)).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (candidates) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${candidates.length} candidates found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Searched 4.2M records · 23.4 seconds',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'IBM Plex Mono'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSortChip('Rank', isSelected: true),
                    _buildSortChip('Confidence'),
                    _buildSortChip('Age match'),
                    _buildSortChip('Restoration'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  return CandidateCard(caseId: caseId, jobId: jobId, candidate: candidates[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: OutlinedButton(
          onPressed: () async {
            final success = await ref.read(casesRepositoryProvider).promoteToUnidentified(caseId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Case added to unidentified database' : 'Failed to add to database')),
              );
            }
          },
          child: const Text('NO MATCH? ADD TO UNIDENTIFIED DATABASE'),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final String caseId;
  final String jobId;
  final dynamic candidate;
  const CandidateCard({super.key, required this.caseId, required this.jobId, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final int rank = candidate['rank'] ?? 0;
    final double confidence = (candidate['confidence'] ?? 0.0).toDouble();
    final String recordId = candidate['record_id'] ?? 'Unknown';
    final List<dynamic> highlights = candidate['features'] ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/cases/$caseId/results/$jobId/candidates/${candidate['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRankBadge(rank, confidence),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unidentified Record #$recordId',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Interpol Red Notice · 2021', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(confidence),
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      const Text('MATCH', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ConfidenceBreakdownCard(
                      scores: {
                        'Morphology': (candidate['morphology'] ?? 0.0).toDouble(),
                        'Restoration': (candidate['restoration'] ?? 0.0).toDouble(),
                        'Spatial': (candidate['spatial'] ?? 0.0).toDouble(),
                        'Age': (candidate['age'] ?? 0.0).toDouble(),
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: highlights.map((h) => MatchFeatureChip(label: '$h ✓')).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank, double confidence) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getConfidenceColor(confidence).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: _getConfidenceColor(confidence)),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: _getConfidenceColor(confidence),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 0.90) return AppColors.success;
    if (score >= 0.70) return AppColors.warning;
    return AppColors.error;
  }
}

class MatchFeatureChip extends StatelessWidget {
  final String label;
  const MatchFeatureChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontFamily: 'IBM Plex Mono'),
      ),
    );
  }
}
