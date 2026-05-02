# Forensodont Multimodal OPG Intelligence

A multimodal forensic dental imaging platform for OPG analysis, evidence triage, and assisted identification using AI/ML on AMD GPU infrastructure.

## Project Structure

- `/mobile`: Flutter mobile application for capture, review, and reporting.
- `/backend`: FastAPI backend with multimodal inference and job orchestration.
- `/docker-compose.yml`: Local development orchestration.

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Flutter SDK
- Python 3.11+ (for local backend development)

### Backend Setup
1. Navigate to `/backend`
2. Create a `.env` file (see `app/core/config.py` for variables)
3. Run `docker-compose up --build`

### Mobile Setup
1. Navigate to `/mobile`
2. Run `flutter pub get`
3. Run `flutter run`

## AI Pipeline
The platform is designed to combine OPG image analysis with optional audio notes and video snippets into a unified evidence workflow. The current codebase provides the app shell, async backend jobs, report generation, and matching-style results views that can be adapted into multimodal analysis.

## Multimodal Demo Flow
1. Upload OPG image: `POST /api/v1/opg/cases/{case_id}/opg`
2. Optionally upload audio note: `POST /api/v1/opg/cases/{case_id}/audio`
3. Optionally upload video snippet: `POST /api/v1/opg/cases/{case_id}/video`
4. Start analysis:

```json
POST /api/v1/match/
{
	"case_id": "<uuid>",
	"opg_image_id": "<uuid>",
	"filters": {
		"audio_note": "fracture near molar and possible implant evidence",
		"video_asset_path": "uploads/video_<id>_clip.mp4"
	}
}
```

The matching worker now runs preprocessing, segmentation, ResNet-50 embeddings, optional video frame embeddings, and fused evidence highlights in a single result stream.

## Hackathon Positioning
This project can be pitched as a forensic dentistry multimodal assistant optimized for AMD Instinct MI300X on ROCm, with a focus on high-throughput image-heavy analysis, clinician review, and structured reporting.
