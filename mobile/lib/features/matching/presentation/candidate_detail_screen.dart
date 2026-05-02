import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:photo_view/photo_view.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/matching_providers.dart';
import 'widgets/opg_viewer.dart';

class CandidateDetailScreen extends ConsumerStatefulWidget {
  final String caseId;
  final String jobId;
  final String candidateId;

  const CandidateDetailScreen({
    super.key,
    required this.caseId,
    required this.jobId,
    required this.candidateId,
  });

  @override
  ConsumerState<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends ConsumerState<CandidateDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PhotoViewController _pmController;
  late PhotoViewController _amController;
  double _overlayOpacity = 0.5;
  bool _showAnnotations = true;
  bool _isSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pmController = PhotoViewController();
    _amController = PhotoViewController();

    _pmController.outputStateStream.listen((state) {
      if (_isSyncEnabled) {
        _amController.value = state;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pmController.dispose();
    _amController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.candidateId),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'COMPARISON'),
            Tab(text: 'TOOTH TABLE'),
            Tab(text: 'PROFILE'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              // Navigate to Screen 7 - Annotation
            },
          ),
        ],
      ),
      body: ref.watch(candidateDetailsProvider((jobId: widget.jobId, candidateId: widget.candidateId))).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (candidate) {
          if (candidate == null) return const Center(child: Text('Candidate not found'));
          
          return TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildComparisonTab(),
              _buildTableTab(),
              _buildProfileTab(candidate),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildComparisonTab() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black,
                      child: const Center(child: Text('POST-MORTEM', style: TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                    ),
                    Expanded(
                      child: OPGViewer(
                        image: const NetworkImage('https://via.placeholder.com/800x400'),
                        controller: _pmController,
                        showAnnotations: _showAnnotations,
                        annotations: [
                          ToothAnnotation(rect: const Rect.fromLTWH(100, 100, 40, 60), label: '36', color: AppColors.success),
                          ToothAnnotation(rect: const Rect.fromLTWH(200, 100, 40, 60), label: '46', color: AppColors.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black,
                      child: const Center(child: Text('ANTE-MORTEM', style: TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                    ),
                    Expanded(
                      child: OPGViewer(
                        image: const NetworkImage('https://via.placeholder.com/800x400'),
                        controller: _amController,
                        showAnnotations: _showAnnotations,
                        annotations: [
                          ToothAnnotation(rect: const Rect.fromLTWH(100, 100, 40, 60), label: '36', color: AppColors.success),
                          ToothAnnotation(rect: const Rect.fromLTWH(200, 100, 40, 60), label: '46', color: AppColors.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildComparisonControls(),
      ],
    );
  }

  Widget _buildComparisonControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.layers_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Text('Overlay Opacity', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _overlayOpacity,
                  onChanged: (val) => setState(() => _overlayOpacity = val),
                  activeColor: AppColors.primary,
                ),
              ),
              Text('${(_overlayOpacity * 100).toInt()}%', style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlChip('Sync View', _isSyncEnabled, () => setState(() => _isSyncEnabled = !_isSyncEnabled)),
              _buildControlChip('Annotations', _showAnnotations, () => setState(() => _showAnnotations = !_showAnnotations)),
              _buildControlChip('Invert Colors', false, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlChip(String label, bool active, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: active ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
      side: BorderSide(color: active ? AppColors.primary : AppColors.border),
      onPressed: onTap,
    );
  }

  Widget _buildTableTab() {
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('FDI')),
          DataColumn(label: Text('PM')),
          DataColumn(label: Text('AM')),
          DataColumn(label: Text('Status')),
        ],
        rows: List.generate(10, (index) => DataRow(
          cells: [
            DataCell(Text('${11 + index}', style: const TextStyle(fontFamily: 'IBM Plex Mono'))),
            const DataCell(Text('Sound')),
            const DataCell(Text('Sound')),
            DataCell(_buildMatchStatusChip('Match')),
          ],
        )),
      ),
    );
  }

  Widget _buildMatchStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: const Text('✓', style: TextStyle(color: AppColors.success, fontSize: 10)),
    );
  }

  Widget _buildProfileTab(Map<String, dynamic> candidate) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subject Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInfoRow('Name', candidate['subject_name'] ?? 'Unknown'),
          _buildInfoRow('Date of Birth', candidate['dob'] ?? 'Unknown'),
          _buildInfoRow('Nationality', candidate['nationality'] ?? 'Unknown'),
          _buildInfoRow('Last Seen', candidate['last_seen'] ?? 'Unknown'),
          _buildInfoRow('Record Source', candidate['record_source'] ?? 'Unknown'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('LINK TO MISSING PERSONS RECORD'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'IBM Plex Mono')),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              child: const Text('REJECT'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Show comment dialog then confirm
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              child: const Text('CONFIRM MATCH'),
            ),
          ),
        ],
      ),
    );
  }
}
