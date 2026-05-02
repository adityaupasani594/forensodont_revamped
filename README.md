# Forensodont OPG Forensic Platform

A production-grade forensic dental identification platform using AI/ML for OPG (orthopantomogram) matching.

## Project Structure

- `/mobile`: Flutter mobile application.
- `/backend`: FastAPI backend with ML inference pipeline.
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
The system uses a ResNet-50 backbone for feature extraction and FAISS for vector similarity search. OPG images are preprocessed using CLAHE and normalization before inference.
