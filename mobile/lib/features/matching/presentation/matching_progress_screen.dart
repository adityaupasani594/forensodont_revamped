import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/match_progress_timeline.dart';
import '../data/matching_repository.dart';


class MatchingProgressScreen extends ConsumerStatefulWidget {
  final String caseId;
  final String jobId;
  const MatchingProgressScreen({super.key, required this.caseId, required this.jobId});

  @override
  ConsumerState<MatchingProgressScreen> createState() => _MatchingProgressScreenState();
}

class _MatchingProgressScreenState extends ConsumerState<MatchingProgressScreen> {
  late Stream<dynamic> _progressStream;

  @override
  void initState() {
    super.initState();
    _progressStream = ref.read(matchingRepositoryProvider).getProgressStream(widget.jobId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Animated dental arch illustration placeholder
              _buildAnimatedArch(),
              const SizedBox(height: 48),
              Text(
                'Processing Case ${widget.caseId}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Searching 4,200,000 records...',
                style: TextStyle(color: AppColors.primary, fontFamily: 'IBM Plex Mono'),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: StreamBuilder(
                  stream: _progressStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data;
                      if (data['status'] == 'complete' || data['stage'] == 'complete') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/cases/${widget.caseId}/results/${widget.jobId}');
                        });
                      }
                      
                      final stage = data['stage'];
                      // Map backend stages to UI stages
                      return MatchProgressTimeline(
                        stages: [
                          MatchStage(
                            label: 'Segmenting teeth...', 
                            isCompleted: stage != 'segmentation' && stage != null,
                            isActive: stage == 'segmentation',
                          ),
                          MatchStage(
                            label: 'Extracting features...', 
                            isCompleted: stage == 'matching' || stage == 'complete', 
                            isActive: stage == 'feature_extraction',
                          ),
                          MatchStage(
                            label: 'Running search...', 
                            isCompleted: stage == 'complete',
                            isActive: stage == 'matching',
                          ),
                        ],
                      );

                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedArch() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          const Icon(Icons.hub_outlined, size: 80, color: AppColors.primary),
        ],
      ),
    );
  }
}
