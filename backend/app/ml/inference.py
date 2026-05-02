import torch
import torch.nn as nn
from torchvision import models
from app.core.config import settings

class ForensicDentalModel(nn.Module):
    def __init__(self):
        super(ForensicDentalModel, self).__init__()
        # Using ResNet50 as a backbone for feature extraction
        self.backbone = models.resnet50(weights=None)
        # Modify first layer to accept grayscale (1 channel)
        self.backbone.conv1 = nn.Conv2d(1, 64, kernel_size=7, stride=2, padding=3, bias=False)
        # Remove the classification head to get embeddings
        self.feature_extractor = nn.Sequential(*list(self.backbone.children())[:-1])
        self.embedding_dim = 2048

    def forward(self, x):
        features = self.feature_extractor(x)
        features = features.view(features.size(0), -1)
        return features

class InferenceEngine:
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = ForensicDentalModel().to(self.device)
        self.model.eval()
        
        # In a real scenario, we would load the weights here
        # torch.load(settings.MODEL_PATH_EMBEDDING, map_location=self.device)

    def get_embedding(self, img_normalized: torch.Tensor):
        with torch.no_grad():
            img_tensor = img_normalized.to(self.device)
            embedding = self.model(img_tensor)
            return embedding.cpu().numpy().flatten().tolist()

inference_engine = InferenceEngine()
