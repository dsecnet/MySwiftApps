"""
ML Model Manager — Singleton pattern ile model yuklenme ve cache

Modelleri bir defe RAM-a yukleyir, tekrar istifade edir.
GPU/CPU auto-detect, model versiya idareetmesi.
"""

import logging
import threading
from pathlib import Path
from typing import Optional

import torch

logger = logging.getLogger(__name__)

# Model saxlama qovlugu
MODEL_DIR = Path(__file__).parent / "weights"
MODEL_DIR.mkdir(exist_ok=True)


class ModelManager:
    """Singleton ML Model Manager"""

    _instance: Optional["ModelManager"] = None
    _lock = threading.Lock()

    def __new__(cls):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super().__new__(cls)
                cls._instance._initialized = False
            return cls._instance

    def __init__(self):
        if self._initialized:
            return
        self._initialized = True

        # Device auto-detect
        if torch.cuda.is_available():
            self.device = torch.device("cuda")
            logger.info("ML Models: GPU (CUDA) istifade olunur")
        elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
            self.device = torch.device("mps")
            logger.info("ML Models: Apple Silicon (MPS) istifade olunur")
        else:
            self.device = torch.device("cpu")
            logger.info("ML Models: CPU istifade olunur")

        # Model cache
        self._food_detector = None
        self._food_classifier = None
        self._recommendation_model = None

        logger.info(f"ModelManager initialized. Device: {self.device}")

    @property
    def food_detector(self):
        """Lazy-load YOLOv8 food detector"""
        if self._food_detector is None:
            from app.ml.food_detector import FoodDetector
            self._food_detector = FoodDetector(device=self.device)
            logger.info("YOLOv8 Food Detector yuklendi")
        return self._food_detector

    @property
    def food_classifier(self):
        """Lazy-load EfficientNet food classifier"""
        if self._food_classifier is None:
            from app.ml.food_classifier import FoodClassifier
            self._food_classifier = FoodClassifier(device=self.device)
            logger.info("EfficientNet Food Classifier yuklendi")
        return self._food_classifier

    @property
    def recommendation_engine(self):
        """Lazy-load XGBoost recommendation engine"""
        if self._recommendation_model is None:
            from app.ml.recommendation_engine import RecommendationEngine
            self._recommendation_model = RecommendationEngine()
            logger.info("XGBoost Recommendation Engine yuklendi")
        return self._recommendation_model

    def preload_all(self):
        """Server basladiqda butun modelleri yukle (optional)"""
        logger.info("Butun ML modelleri yuklenir...")
        _ = self.food_detector
        _ = self.food_classifier
        _ = self.recommendation_engine
        logger.info("Butun ML modelleri yuklendi!")


# Global singleton
model_manager = ModelManager()
