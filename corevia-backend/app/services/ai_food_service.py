"""
AI Food Analysis Service — Local ML (YOLOv8 + EfficientNet + USDA)

Sekildeki yemeleri analiz edir:
1. YOLOv8 ile deteksiya (bbox)
2. EfficientNet ile classify
3. USDA Database ile beslenme deyerleri

Xarici AI API (Claude, OpenAI vs.) istifade ETMIR — tam local ML.
"""

import io
import logging
from typing import Dict

from PIL import Image

logger = logging.getLogger(__name__)


class AIFoodService:
    """Local ML-based food analysis service"""

    def __init__(self):
        self._detector = None
        self._classifier = None
        self._food_db = None

    def _ensure_loaded(self):
        """Lazy-load ML components"""
        if self._detector is None:
            from app.ml.food_detector import FoodDetector
            self._detector = FoodDetector()

        if self._classifier is None:
            from app.ml.food_classifier import FoodClassifier
            self._classifier = FoodClassifier()

        if self._food_db is None:
            from app.ml.food_database import food_database
            self._food_db = food_database

    async def analyze_food_image(
        self,
        image_base64: str,
        language: str = "az",
        media_type: str = "image/jpeg"
    ) -> Dict:
        """
        Sekildeki yemekleri analiz et — Local ML Pipeline:
        1. YOLOv8 detect → bbox-lar
        2. EfficientNet classify → yemek adlari
        3. USDA DB lookup → kalori/makro deyerleri
        4. Aggregate → total response

        Response formati eskisi ile eynidir (iOS uygunlugu qorunur).
        """
        try:
            self._ensure_loaded()

            # Base64 → bytes
            import base64
            try:
                image_bytes = base64.b64decode(image_base64)
            except Exception:
                return {
                    "success": False,
                    "error": "Sekil decode edilmedi. Duzgun base64 gonderin."
                }

            # Validate image
            try:
                img = Image.open(io.BytesIO(image_bytes))
                if img.size[0] < 50 or img.size[1] < 50:
                    return {
                        "success": False,
                        "error": "Sekil cox kicikdir. Daha boyuk sekil yukleyin."
                    }
            except Exception:
                return {
                    "success": False,
                    "error": "Sekil acilmadi. Duzgun format gonderin (JPEG/PNG)."
                }

            # Step 1: YOLOv8 Food Detection
            detections = self._detector.detect_foods(image_bytes)

            if not detections:
                return {
                    "success": False,
                    "error": "Sekilde qida askar edilmedi."
                }

            # Step 2+3: Classify each detection + USDA lookup
            foods_found = []
            total_calories = 0
            total_protein = 0.0
            total_carbs = 0.0
            total_fats = 0.0
            total_confidence = 0.0

            for det in detections:
                crop_image = det.get("crop")
                det_confidence = det.get("confidence", 0.5)

                if crop_image is None:
                    continue

                # EfficientNet classify
                classification = self._classifier.classify(crop_image)
                food_name = classification.get("display_name", "Food")
                cls_confidence = classification.get("confidence", 0.5)

                # USDA database lookup
                nutrition = self._food_db.get_nutrition(food_name)

                if nutrition:
                    foods_found.append({
                        "name": nutrition["food_name"],
                        "calories": nutrition["calories"],
                        "protein": nutrition["protein"],
                        "carbs": nutrition["carbs"],
                        "fats": nutrition["fat"],
                        "portion_size": nutrition["portion_desc"],
                    })

                    total_calories += nutrition["calories"]
                    total_protein += nutrition["protein"]
                    total_carbs += nutrition["carbs"]
                    total_fats += nutrition["fat"]

                    # Orta confidence: detection * classification * db_match
                    db_conf = nutrition.get("confidence", 0.7)
                    combined_conf = det_confidence * cls_confidence * db_conf
                    total_confidence += combined_conf

            if not foods_found:
                return {
                    "success": False,
                    "error": "Sekilde qida askar edilmedi ve ya analiz etmek mumkun olmadi."
                }

            # Average confidence
            avg_confidence = total_confidence / len(foods_found) if foods_found else 0.5

            # Confidence cap (0.95 max — hec vaxt 100% emin olma)
            avg_confidence = min(avg_confidence, 0.95)

            # Combine food names
            food_names = ", ".join(f["name"] for f in foods_found)

            # Porsiya olcusu (birden cox yemek varsa aggregate)
            if len(foods_found) == 1:
                portion_size = foods_found[0]["portion_size"]
            else:
                total_g = sum(
                    self._food_db.get_nutrition(f["name"]).get("portion_g", 200)
                    for f in foods_found
                )
                portion_size = f"{len(foods_found)} yemek (~{total_g}g)"

            return {
                "success": True,
                "food_name": food_names,
                "calories": total_calories,
                "protein": round(total_protein, 1),
                "carbs": round(total_carbs, 1),
                "fats": round(total_fats, 1),
                "portion_size": portion_size,
                "confidence": round(avg_confidence, 2),
                "foods_detail": foods_found,
            }

        except Exception as e:
            logger.error(f"ML food analysis xetasi: {e}", exc_info=True)
            return {
                "success": False,
                "error": "AI analizi ugursuz oldu. Yeniden cehd edin."
            }

    def _mock_analysis(self) -> Dict:
        """Test ucun mock data (ML model yuklenmeyende)"""
        import random

        mock_foods = [
            {"name": "Plov", "cal": 630, "p": 19.3, "c": 87.5, "f": 24.5, "portion": "1 boşqab (~350g)"},
            {"name": "Düşbərə", "cal": 360, "p": 25.5, "c": 42.0, "f": 10.5, "portion": "1 kasa (~300g)"},
            {"name": "Qutab", "cal": 420, "p": 14.0, "c": 56.0, "f": 16.0, "portion": "2 ədəd (~200g)"},
            {"name": "Lule Kebab", "cal": 550, "p": 45.0, "c": 5.0, "f": 40.0, "portion": "1 porsiya (~250g)"},
            {"name": "Salad", "cal": 40, "p": 3.0, "c": 7.0, "f": 0.4, "portion": "1 qab (~200g)"},
        ]

        food = random.choice(mock_foods)
        logger.info("MOCK MODE: ML Food Analysis (model yuklenmeyib)")

        return {
            "success": True,
            "food_name": food["name"],
            "calories": food["cal"],
            "protein": food["p"],
            "carbs": food["c"],
            "fats": food["f"],
            "portion_size": food["portion"],
            "confidence": 0.85,
            "is_mock": True,
        }


# Singleton instance
ai_food_service = AIFoodService()
