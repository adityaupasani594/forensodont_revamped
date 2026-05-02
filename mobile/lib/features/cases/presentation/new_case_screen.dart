import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/fdi_tooth_chart.dart';
import 'widgets/quality_indicator.dart';
import '../../matching/data/matching_repository.dart';
import '../data/cases_repository.dart';
import '../../reports/data/reports_repository.dart';



class NewCaseScreen extends ConsumerStatefulWidget {
  const NewCaseScreen({super.key});

  @override
  ConsumerState<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends ConsumerState<NewCaseScreen> {
  int _currentStep = 0;
  final Set<int> _missingTeeth = {};
  RangeValues _ageRange = const RangeValues(28, 45);
  String _selectedSex = 'Unknown';
  String? _caseId;
  String? _opgImageId = 'opg-mock-uuid'; // This would come from an actual upload in a real app
  
  // Simulation of preprocessing stages
  final List<Map<String, dynamic>> _preprocessingStages = [
    {'label': 'Denoising image...', 'status': 'done'},
    {'label': 'Normalising contrast...', 'status': 'done'},
    {'label': 'Correcting orientation...', 'status': 'loading'},
    {'label': 'Assessing quality...', 'status': 'pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Case'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: _buildStepContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step ${_currentStep + 1} of 4', style: Theme.of(context).textTheme.labelMedium),
              Text(_getStepTitle(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Case Details';
      case 1: return 'OPG Capture';
      case 2: return 'Preprocessing';
      case 3: return 'Search Filters';
      default: return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildDetailsStep();
      case 1: return _buildCaptureStep();
      case 2: return _buildPreprocessingStep();
      case 3: return _buildFiltersStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Case Reference Number'),
          TextFormField(
            initialValue: 'CASE-2023-482',
            decoration: const InputDecoration(hintText: 'Enter case ID'),
            style: const TextStyle(fontFamily: 'IBM Plex Mono'),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Incident Name'),
          TextFormField(decoration: const InputDecoration(hintText: 'e.g. Operation Northern Star')),
          const SizedBox(height: 20),
          _buildFieldLabel('Location'),
          TextFormField(decoration: const InputDecoration(hintText: 'City, Country')),
          const SizedBox(height: 20),
          _buildFieldLabel('Investigator Name'),
          TextFormField(initialValue: 'Det. Sarah Miller'),
          const SizedBox(height: 20),
          _buildFieldLabel('Notes'),
          TextFormField(
            onChanged: (val) {},
            maxLines: 4, 
            decoration: const InputDecoration(hintText: 'Additional details...')
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Camera'), icon: Icon(Icons.camera_alt)),
              ButtonSegment(value: 1, label: Text('Import'), icon: Icon(Icons.file_upload)),
            ],
            selected: {0},
            onSelectionChanged: (set) {},
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.camera_alt, size: 64, color: AppColors.surface)),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: CustomPaint(painter: DentalArchPainter()),
                  ),
                ),
                const Positioned(
                  top: 16,
                  right: 16,
                  child: QualityIndicatorOverlay(),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Align the dental arch silhouette with the X-ray for optimal capture.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildPreprocessingStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: Icon(Icons.image, size: 100, color: AppColors.surface)),
            ),
          ),
          const SizedBox(height: 24),
          ..._preprocessingStages.map((stage) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                if (stage['status'] == 'done')
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                else if (stage['status'] == 'loading')
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  const Icon(Icons.circle_outlined, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(stage['label'], style: TextStyle(
                  color: stage['status'] == 'pending' ? AppColors.textSecondary : AppColors.textPrimary,
                )),
              ],
            ),
          )),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Image quality: 87% — Good', style: TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.verified, color: AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Demographic Filters'),
          _buildFieldLabel('Age range: ${_ageRange.start.round()}–${_ageRange.end.round()} years'),
          RangeSlider(
            values: _ageRange,
            min: 0,
            max: 100,
            onChanged: (val) => setState(() => _ageRange = val),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Biological sex'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Male', label: Text('Male')),
              ButtonSegment(value: 'Female', label: Text('Female')),
              ButtonSegment(value: 'Unknown', label: Text('Unknown')),
            ],
            selected: {_selectedSex},
            onSelectionChanged: (set) => setState(() => _selectedSex = set.first),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Clinical filters — Tooth chart'),
          const Text('Mark any teeth absent from the OPG', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          FDIToothChart(
            missingTeeth: _missingTeeth,
            onToothTap: (id) => setState(() {
              if (_missingTeeth.contains(id)) {
                _missingTeeth.remove(id);
              } else {
                _missingTeeth.add(id);
              }
            }),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Clinical filters — Restorations'),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Amalgam fillings'),
              _buildFilterChip('Composite fillings'),
              _buildFilterChip('Gold crowns'),
              _buildFilterChip('Porcelain crowns'),
              _buildFilterChip('Root canal'),
              _buildFilterChip('Dental implants'),
              _buildFilterChip('Fixed bridges'),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Clinical filters — Anomalies'),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Taurodontism'),
              _buildFilterChip('Hypodontia'),
              _buildFilterChip('Supernumerary teeth'),
              _buildFilterChip('Impacted wisdom teeth'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: false,
      onSelected: (val) {},
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: AppColors.border)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('BACK'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentStep == 0) {
                  // Create case
                  final newCase = await ref.read(casesRepositoryProvider).createCase({
                    'reference_number': 'CASE-${DateTime.now().millisecondsSinceEpoch}',
                    'incident_name': 'Operation Northern Star',
                    'location': 'New York, USA',
                  });
                  if (newCase != null) {
                    setState(() {
                      _caseId = newCase.id;
                      _currentStep++;
                    });
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create case')),
                      );
                    }
                  }
                } else if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  // Trigger real match search
                  if (_caseId == null) return;

                  final result = await ref.read(matchingRepositoryProvider).startMatch(
                    _caseId!,
                    _opgImageId ?? 'mock-opg-id', 
                    {
                      'age_min': _ageRange.start.round(),
                      'age_max': _ageRange.end.round(),
                      'sex': _selectedSex,
                      'missing_teeth': _missingTeeth.toList(),
                    },
                  );
                  
                  if (result != null && result['job_id'] != null) {
                    if (mounted) {
                      context.push('/cases/$_caseId/matching/${result['job_id']}');
                    }
                  }
                }
              },
              child: Text(_currentStep == 3 ? 'RUN SEARCH' : 'CONTINUE'),
            ),
          ),


        ],
      ),
    );
  }
}

class DentalArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.9, size.height * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QualityIndicatorOverlay extends StatelessWidget {
  const QualityIndicatorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          QualityIndicator(label: 'SHARPNESS', score: 3),
          QualityIndicator(label: 'EXPOSURE', score: 4),
          QualityIndicator(label: 'ALIGNMENT', score: 5),
        ],
      ),
    );
  }
}
