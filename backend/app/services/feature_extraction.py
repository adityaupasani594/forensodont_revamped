import numpy as np
from app.services.segmentation import SegmentationResult

def extract_features(image_path: str, segmentation: SegmentationResult) -> np.ndarray:
    """
    Extracts a composite feature vector for similarity matching.
    Returns: FeatureVector (numpy array, float32, shape [544])
    """
    # Mocking feature extraction
    # Concatenate per-tooth morphology (N×32 floats) → pooled to 256 floats
    # Restoration encoding (N×16 binary/float) → pooled to 128 floats
    # Spatial GNN embedding: 128 floats
    # Global age/sex features: 32 floats
    # Total: 544-dimensional float vector (L2-normalised)
    
    # Generate random 544-dimensional vector
    vector = np.random.rand(544).astype(np.float32)
    
    # L2 normalize
    norm = np.linalg.norm(vector)
    if norm > 0:
        vector = vector / norm
        
    return vector
