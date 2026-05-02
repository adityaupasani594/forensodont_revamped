from pathlib import Path
import warnings

import torch
import torch.nn as nn
from PIL import Image
from torchvision import models, transforms
from torchvision.models import ResNet50_Weights


class ForensicDentalModel(nn.Module):
    def __init__(self):
        super().__init__()
        try:
            weights = ResNet50_Weights.DEFAULT
            backbone = models.resnet50(weights=weights)
            self.preprocess = weights.transforms()
        except Exception:
            warnings.warn("Falling back to an untrained ResNet-50 backbone; pretrained weights were unavailable.")
            backbone = models.resnet50(weights=None)
            self.preprocess = transforms.Compose(
                [
                    transforms.Resize((224, 224)),
                    transforms.ToTensor(),
                    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
                ]
            )
        self.feature_extractor = nn.Sequential(*list(backbone.children())[:-1])
        self.embedding_dim = 2048

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        features = self.feature_extractor(x)
        return features.view(features.size(0), -1)


class InferenceEngine:
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = ForensicDentalModel().to(self.device)
        self.transform = self.model.preprocess
        self.model.eval()

    def _load_image(self, image_path: str) -> torch.Tensor:
        image = Image.open(Path(image_path)).convert("RGB")
        return self.transform(image).unsqueeze(0)

    def get_embedding(self, img_normalized: torch.Tensor):
        with torch.no_grad():
            img_tensor = img_normalized.to(self.device)
            embedding = self.model(img_tensor)
            embedding = torch.nn.functional.normalize(embedding, p=2, dim=1)
            return embedding.cpu().numpy().flatten().astype("float32").tolist()

    def get_embedding_from_image(self, image_path: str):
        image_tensor = self._load_image(image_path)
        return self.get_embedding(image_tensor)


inference_engine = InferenceEngine()
