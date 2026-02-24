"""
AI Service — Local ML (XGBoost Recommendations + Pillow Trainer Verification)

Xarici AI API (Claude, OpenAI vs.) istifade ETMIR.
Tovsiyeler: app/ml/recommendation_engine.py (rule-based + XGBoost)
Trainer verification: Pillow image quality + manual review
"""

import io
import base64
import logging

from PIL import Image

logger = logging.getLogger(__name__)


async def analyze_food_image(image_data: bytes) -> dict:
    """ML ile sekildeki yemekleri analiz et"""
    from app.ml.food_detector import FoodDetector
    from app.ml.food_classifier import FoodClassifier
    from app.ml.food_database import food_database

    try:
        detector = FoodDetector()
        classifier = FoodClassifier()

        detections = detector.detect_foods(image_data)

        if not detections:
            return {"error": "Sekilde qida askar edilmedi."}

        foods = []
        total_cal = 0
        total_p = 0.0
        total_c = 0.0
        total_f = 0.0

        for det in detections:
            crop = det.get("crop")
            if crop is None:
                continue

            classification = classifier.classify(crop)
            food_name = classification.get("display_name", "Food")
            nutrition = food_database.get_nutrition(food_name)

            if nutrition:
                foods.append({
                    "name": nutrition["food_name"],
                    "calories": nutrition["calories"],
                    "protein": nutrition["protein"],
                    "carbs": nutrition["carbs"],
                    "fats": nutrition["fat"],
                    "portion_size": nutrition["portion_desc"],
                })
                total_cal += nutrition["calories"]
                total_p += nutrition["protein"]
                total_c += nutrition["carbs"]
                total_f += nutrition["fat"]

        if not foods:
            return {"error": "Sekilde qida askar edilmedi."}

        return {
            "foods": foods,
            "total_calories": total_cal,
            "total_protein": round(total_p, 1),
            "total_carbs": round(total_c, 1),
            "total_fats": round(total_f, 1),
            "meal_type": "lunch",
            "confidence": 0.75,
            "notes": f"{len(foods)} yemek tapildi",
        }

    except Exception as e:
        logger.error(f"ML food analysis xetasi: {e}", exc_info=True)
        return {"error": "AI analizi ugursuz oldu. Yeniden cehd edin."}


async def get_user_recommendations(user_data: dict) -> dict:
    """Local ML ile tovsiyeler generasiya et"""
    try:
        from app.ml.recommendation_engine import RecommendationEngine

        engine = RecommendationEngine()
        survey_data = user_data.pop("survey_data", None)

        result = engine.generate_recommendations(
            user_data=user_data,
            survey_data=survey_data,
            language="az",
        )
        return result

    except Exception as e:
        logger.error(f"ML recommendation xetasi: {e}", exc_info=True)
        return _mock_recommendations()


def validate_image_basic(image_data: bytes) -> dict:
    """Pillow ile seklin keyfiyyetini yoxla"""
    issues = []
    quality_score = 1.0

    try:
        img = Image.open(io.BytesIO(image_data))
    except Exception:
        return {
            "is_valid": False, "width": 0, "height": 0,
            "aspect_ratio": 0, "file_size_kb": len(image_data) // 1024,
            "format": "unknown", "is_photo": False,
            "quality_score": 0.0, "issues": ["invalid_image_file"],
        }

    width, height = img.size
    file_size_kb = len(image_data) // 1024
    fmt = (img.format or "unknown").upper()
    aspect_ratio = round(width / max(height, 1), 2)

    if width < 200 or height < 200:
        issues.append("too_small"); quality_score -= 0.4
    if file_size_kb < 10:
        issues.append("file_too_small"); quality_score -= 0.3
    if fmt not in ("JPEG", "JPG", "PNG", "HEIC", "HEIF", "WEBP"):
        issues.append("unsupported_format"); quality_score -= 0.2
    if aspect_ratio > 3.0 or aspect_ratio < 0.3:
        issues.append("unusual_aspect_ratio"); quality_score -= 0.3

    try:
        small = img.resize((50, 50)).convert("RGB")
        pixels = list(small.getdata())
        unique_colors = len(set(pixels))
        if unique_colors < 50:
            issues.append("low_color_variety"); quality_score -= 0.3
        from collections import Counter
        color_counts = Counter(pixels)
        most_common_count = color_counts.most_common(1)[0][1]
        if most_common_count > 2250:
            issues.append("mostly_solid_color"); quality_score -= 0.5
    except Exception:
        pass

    if file_size_kb < 50 and width < 400:
        issues.append("likely_not_real_photo"); quality_score -= 0.2

    is_photo = len(issues) == 0 or (len(issues) <= 1 and "likely_not_real_photo" not in issues)
    quality_score = max(0.0, min(1.0, quality_score))

    return {
        "is_valid": quality_score > 0.2, "width": width, "height": height,
        "aspect_ratio": aspect_ratio, "file_size_kb": file_size_kb,
        "format": fmt, "is_photo": is_photo,
        "quality_score": round(quality_score, 2), "issues": issues,
    }


async def analyze_trainer_photo(image_data: bytes) -> dict:
    """Trainer fitness formasini analiz et — Pillow + heuristic"""
    img_info = validate_image_basic(image_data)
    logger.info(f"Image validation: {img_info}")

    if not img_info["is_valid"]:
        return {
            "is_fitness_person": False, "confidence_score": 0.0,
            "analysis": f"Sekil keyfiyyetsizdir. Problemler: {', '.join(img_info['issues'])}",
            "body_composition": "below_average", "visible_muscle_definition": False,
            "fitness_indicators": [], "red_flags": img_info["issues"],
            "photo_quality": "invalid", "image_validation": img_info,
        }

    quality = img_info["quality_score"]
    issues = img_info["issues"]

    if quality < 0.3 or "mostly_solid_color" in issues:
        return {
            "is_fitness_person": False, "confidence_score": 0.10,
            "analysis": "Sekil keyfiyyeti cox asagidir.",
            "body_composition": "below_average", "visible_muscle_definition": False,
            "fitness_indicators": [], "red_flags": issues,
            "photo_quality": "invalid", "image_validation": img_info,
            "requires_manual_review": True,
        }

    if quality < 0.7 or len(issues) >= 2:
        return {
            "is_fitness_person": False, "confidence_score": 0.35,
            "analysis": "Sekil yuklendi. Admin yoxlayacaq.",
            "body_composition": "average", "visible_muscle_definition": False,
            "fitness_indicators": [], "red_flags": issues or ["quality_below_threshold"],
            "photo_quality": "poor", "image_validation": img_info,
            "requires_manual_review": True,
        }

    return {
        "is_fitness_person": True, "confidence_score": 0.60,
        "analysis": "Sekil keyfiyyeti yaxsidir. Admin yoxlayacaq.",
        "body_composition": "average", "visible_muscle_definition": False,
        "fitness_indicators": [], "red_flags": [],
        "photo_quality": "good", "image_validation": img_info,
        "requires_manual_review": True,
    }


def _mock_recommendations() -> dict:
    """Fallback tovsiyeler"""
    return {
        "summary": "Default tovsiyeler.",
        "nutrition_tips": ["Gunde 2L su icin", "Protein artirin", "Sebze-meyve yeyin"],
        "workout_tips": ["Heftelik 3-4 mesq", "Kardio+guc birlesdirin", "Istirahete vaxt ayirin"],
        "warnings": [], "weekly_score": 50,
    }
