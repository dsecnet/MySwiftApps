"""
YOLOv8 Food Detector

Pre-trained YOLOv8n modeli ile sekildeki yemeleri detekt edir.
Multi-food detection — bir sekilde bir nece yemek tapa bilir.

Xarici AI API istifade etmir — tam local ML.
"""

import io
import logging
from typing import List, Dict, Tuple
from pathlib import Path

import torch
import numpy as np
from PIL import Image

logger = logging.getLogger(__name__)

# Food-101 class adlari (en populyar 101 yemek)
FOOD101_CLASSES = [
    "apple_pie", "baby_back_ribs", "baklava", "beef_carpaccio", "beef_tartare",
    "beet_salad", "beignets", "bibimbap", "bread_pudding", "breakfast_burrito",
    "bruschetta", "caesar_salad", "cannoli", "caprese_salad", "carrot_cake",
    "ceviche", "cheesecake", "cheese_plate", "chicken_curry", "chicken_quesadilla",
    "chicken_wings", "chocolate_cake", "chocolate_mousse", "churros", "clam_chowder",
    "club_sandwich", "crab_cakes", "creme_brulee", "croque_madame", "cup_cakes",
    "deviled_eggs", "donuts", "dumplings", "edamame", "eggs_benedict",
    "escargots", "falafel", "filet_mignon", "fish_and_chips", "foie_gras",
    "french_fries", "french_onion_soup", "french_toast", "fried_calamari", "fried_rice",
    "frozen_yogurt", "garlic_bread", "gnocchi", "greek_salad", "grilled_cheese_sandwich",
    "grilled_salmon", "guacamole", "gyoza", "hamburger", "hot_and_sour_soup",
    "hot_dog", "huevos_rancheros", "hummus", "ice_cream", "lasagna",
    "lobster_bisque", "lobster_roll_sandwich", "macaroni_and_cheese", "macarons", "miso_soup",
    "mussels", "nachos", "omelette", "onion_rings", "oysters",
    "pad_thai", "paella", "pancakes", "panna_cotta", "peking_duck",
    "pho", "pizza", "pork_chop", "poutine", "prime_rib",
    "pulled_pork_sandwich", "ramen", "ravioli", "red_velvet_cake", "risotto",
    "samosa", "sashimi", "scallops", "seaweed_salad", "shrimp_and_grits",
    "spaghetti_bolognese", "spaghetti_carbonara", "spring_rolls", "steak", "strawberry_shortcake",
    "sushi", "tacos", "takoyaki", "tiramisu", "tuna_tartare",
    "waffles",
]

# Food-101 → readable ad mapping
FOOD101_DISPLAY_NAMES = {
    "apple_pie": "Apple Pie",
    "baby_back_ribs": "Ribs",
    "baklava": "Pakhlava",
    "beef_carpaccio": "Beef Carpaccio",
    "caesar_salad": "Caesar Salad",
    "chicken_curry": "Chicken Curry",
    "chicken_wings": "Chicken Wings",
    "chocolate_cake": "Chocolate Cake",
    "dumplings": "Düşbərə",
    "fried_rice": "Plov",
    "french_fries": "French Fries",
    "greek_salad": "Greek Salad",
    "grilled_salmon": "Salmon",
    "hamburger": "Hamburger",
    "hot_dog": "Hot Dog",
    "ice_cream": "Ice Cream",
    "lasagna": "Lasagna",
    "omelette": "Omelette",
    "pancakes": "Pancakes",
    "pizza": "Pizza",
    "ramen": "Ramen",
    "risotto": "Risotto",
    "samosa": "Samosa",
    "sashimi": "Sashimi",
    "spaghetti_bolognese": "Spaghetti",
    "spring_rolls": "Spring Rolls",
    "steak": "Steak",
    "sushi": "Sushi",
    "tacos": "Tacos",
    "waffles": "Waffles",
}


class FoodDetector:
    """
    YOLOv8 ile yemek detection.

    Eger YOLOv8 custom model yuklenmeyibse,
    pre-trained YOLOv8n (COCO) + heuristic istifade edir.
    Food ucun custom weight varsa, onu yukleyir.
    """

    def __init__(self, device: torch.device = None):
        self.device = device or torch.device("cpu")
        self._model = None
        self._custom_model_loaded = False

        # Custom weight path
        self._weight_path = Path(__file__).parent / "weights" / "food_yolov8n.pt"

    def _load_model(self):
        """Model lazy-load"""
        if self._model is not None:
            return

        try:
            from ultralytics import YOLO

            if self._weight_path.exists():
                # Custom food detection model
                self._model = YOLO(str(self._weight_path))
                self._custom_model_loaded = True
                logger.info(f"Custom YOLOv8 food model yuklendi: {self._weight_path}")
            else:
                # Pre-trained COCO model (yemek deyil amma deteksiya edir)
                self._model = YOLO("yolov8n.pt")
                self._custom_model_loaded = False
                logger.info("Pre-trained YOLOv8n (COCO) yuklendi. Custom food model tapilmadi.")

        except ImportError:
            logger.warning("ultralytics yuklu deyil. Fallback mode istifade olunur.")
            self._model = None
        except Exception as e:
            logger.error(f"YOLOv8 yukleme xetasi: {e}")
            self._model = None

    def detect_foods(self, image_data: bytes) -> List[Dict]:
        """
        Sekildeki yemeleri detekt et.

        Returns:
            List[Dict]: Her detekt olunan yemek ucun:
                - class_name: str
                - confidence: float
                - bbox: [x1, y1, x2, y2]
                - crop: PIL.Image (kesik hisse)
        """
        self._load_model()

        try:
            # Sekili PIL Image-e cevir
            image = Image.open(io.BytesIO(image_data)).convert("RGB")
            img_width, img_height = image.size

            if self._model is None:
                # Fallback: butun sekili bir yemek kimi qaytar
                return [{
                    "class_name": "food",
                    "confidence": 0.7,
                    "bbox": [0, 0, img_width, img_height],
                    "crop": image,
                }]

            # YOLOv8 inference
            results = self._model.predict(
                source=image,
                conf=0.25,
                verbose=False,
                device=str(self.device),
            )

            detections = []
            if results and len(results) > 0:
                result = results[0]

                if self._custom_model_loaded:
                    # Custom model — food class-lar
                    for box in result.boxes:
                        cls_id = int(box.cls[0])
                        conf = float(box.conf[0])
                        x1, y1, x2, y2 = box.xyxy[0].tolist()

                        # Crop
                        crop = image.crop((int(x1), int(y1), int(x2), int(y2)))

                        class_name = result.names.get(cls_id, f"food_{cls_id}")

                        detections.append({
                            "class_name": class_name,
                            "confidence": round(conf, 3),
                            "bbox": [int(x1), int(y1), int(x2), int(y2)],
                            "crop": crop,
                        })
                else:
                    # COCO model — yemek ile elaqeli class-lar
                    food_related_classes = {
                        46: "banana", 47: "apple", 48: "sandwich", 49: "orange",
                        50: "broccoli", 51: "carrot", 52: "hot dog", 53: "pizza",
                        54: "donut", 55: "cake", 56: "chair",  # chair yemek deyil amma table olur
                        39: "bottle", 41: "cup", 42: "fork", 43: "knife",
                        44: "spoon", 45: "bowl",
                    }

                    food_only = {46, 47, 48, 49, 50, 51, 52, 53, 54, 55}

                    has_food_class = False
                    for box in result.boxes:
                        cls_id = int(box.cls[0])
                        if cls_id in food_only:
                            has_food_class = True
                            conf = float(box.conf[0])
                            x1, y1, x2, y2 = box.xyxy[0].tolist()
                            crop = image.crop((int(x1), int(y1), int(x2), int(y2)))

                            class_name = food_related_classes.get(cls_id, "food")
                            detections.append({
                                "class_name": class_name,
                                "confidence": round(conf, 3),
                                "bbox": [int(x1), int(y1), int(x2), int(y2)],
                                "crop": crop,
                            })

                    # Eger hec bir food class tapilmadiysa, butun sekili food qebul et
                    if not has_food_class:
                        # Yemek gorunen sekil ola biler — bowl/plate kontekstinde
                        has_dining = any(
                            int(b.cls[0]) in {39, 41, 42, 43, 44, 45}
                            for b in result.boxes
                        )
                        detections.append({
                            "class_name": "food",
                            "confidence": 0.65 if has_dining else 0.5,
                            "bbox": [0, 0, img_width, img_height],
                            "crop": image,
                        })

            if not detections:
                # Hec ne tapilmadiysa, butun sekili food qebul et
                detections.append({
                    "class_name": "food",
                    "confidence": 0.5,
                    "bbox": [0, 0, img_width, img_height],
                    "crop": image,
                })

            return detections

        except Exception as e:
            logger.error(f"Food detection xetasi: {e}")
            # Fallback
            try:
                image = Image.open(io.BytesIO(image_data)).convert("RGB")
                return [{
                    "class_name": "food",
                    "confidence": 0.5,
                    "bbox": [0, 0, image.width, image.height],
                    "crop": image,
                }]
            except Exception:
                return []
