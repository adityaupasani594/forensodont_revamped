import numpy as np
from app.ml.inference import inference_engine
from app.services.segmentation import SegmentationResult

def extract_features(image_path: str, segmentation: SegmentationResult) -> np.ndarray:
    """
    Extracts a composite feature vector for similarity matching.
    Returns: FeatureVector (numpy array, float32, shape [2048])
    """
    # The first production model path is a pretrained ResNet-50 embedding.
    # Segmentation can later be used to crop or mask regions of interest.
    embedding = inference_engine.get_embedding_from_image(image_path)
    vector = np.asarray(embedding, dtype=np.float32)

    norm = np.linalg.norm(vector)
    if norm > 0:
        vector = vector / norm

    return vector
