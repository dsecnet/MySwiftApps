import json
import base64
import io
import logging
import httpx
from PIL import Image
from app.config import get_settings

logger = logging.getLogger(__name__)

settings = get_settings()

# Claude AI setup
_has_valid_key = bool(
    settings.anthropic_api_key
    and not settings.anthropic_api_key.startswith("your-")
    and len(settings.anthropic_api_key) > 20
)
CLAUDE_API_URL = "https://api.anthropic.com/v1/messages"
CLAUDE_MODEL = "claude-sonnet-4-20250514"


async def _call_claude(messages: list, max_tokens: int = 1000) -> str:
    """Anthropic Claude API call helper"""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            CLAUDE_API_URL,
            headers={
                "x-api-key": settings.anthropic_api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": CLAUDE_MODEL,
                "max_tokens": max_tokens,
                "messages": messages,
            }
        )

    if response.status_code != 200:
        raise Exception(f"Claude API error: {response.status_code}")

    data = response.json()
    return data["content"][0]["text"].strip()


def _parse_json_response(content: str) -> dict:
    """Parse JSON from Claude response, handling markdown code blocks"""
    if "```json" in content:
        content = content.split("```json")[1].split("```")[0].strip()
    elif "```" in content:
        content = content.split("```")[1].split("```")[0].strip()
    return json.loads(content)


FOOD_ANALYSIS_PROMPT = """Sen bir qida analiz ekspertisen. Bu sekilde gosterilen yemekleri analiz et.

Cavabini YALNIZ JSON formatinda ver, baska hec ne yazma:
{
    "foods": [
        {
            "name": "yemeyin adi",
            "calories": 250,
            "protein": 15.0,
            "carbs": 30.0,
            "fats": 8.0,
            "portion_size": "1 porsia (200g)"
        }
    ],
    "total_calories": 250,
    "total_protein": 15.0,
    "total_carbs": 30.0,
    "total_fats": 8.0,
    "meal_type": "lunch",
    "confidence": 0.85,
    "notes": "Qisa qeyd"
}

Qaydalar:
- Kalorini ve makrolari texmini hesabla
- meal_type: breakfast, lunch, dinner, snack
- confidence: 0-1 arasi (ne qeder emin oldugun)
- Eger sekilde yemek yoxdursa, "foods" bosq array olsun ve confidence 0 olsun
- Azerbaycan yemeklerini deqiq tani (plov, dolma, qutab, dusbere, dovga ve s.)
- Hemise AZ dilde cavab ver"""


async def analyze_food_image(image_data: bytes) -> dict:
    """Claude Vision API ile sekildeki yemekleri analiz et"""
    if not _has_valid_key:
        return _mock_analysis()

    base64_image = base64.b64encode(image_data).decode("utf-8")

    try:
        content = await _call_claude(
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": FOOD_ANALYSIS_PROMPT},
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64_image,
                            },
                        },
                    ],
                }
            ],
            max_tokens=1000,
        )

        return _parse_json_response(content)

    except json.JSONDecodeError:
        logger.error("Failed to parse Claude food analysis response")
        return {"error": "AI cavabi emal edilmedi. Yeniden cehd edin."}
    except Exception as e:
        logger.error(f"Claude food analysis error: {e}")
        return {"error": "AI analizi ugursuz oldu. Yeniden cehd edin."}


RECOMMENDATION_PROMPT = """Sen bir fitness ve qidalanma mutexessisisen. Asagidaki istifadeci melumatlarini analiz et ve ona sexsi tovsiyeler ver.

Istifadeci melumatlari:
{user_data}

Cavabini YALNIZ JSON formatinda ver:
{{
    "summary": "Umumi qiymetlendirme (2-3 cumle)",
    "nutrition_tips": ["tovsiye 1", "tovsiye 2", "tovsiye 3"],
    "workout_tips": ["tovsiye 1", "tovsiye 2", "tovsiye 3"],
    "warnings": ["xebardarliq (eger varsa)"],
    "weekly_score": 75
}}

Qaydalar:
- weekly_score: 0-100 arasi umumi bal
- Her tovsiye qisa ve konkret olsun
- AZ dilinde cavab ver
- Istifadecinin meqsedine uygun tovsiyeler ver"""


async def get_user_recommendations(user_data: dict) -> dict:
    """Istifadecinin datalarini analiz edib tovsiyeler ver"""
    if not _has_valid_key:
        return _mock_recommendations()

    try:
        content = await _call_claude(
            messages=[
                {
                    "role": "user",
                    "content": RECOMMENDATION_PROMPT.format(
                        user_data=json.dumps(user_data, ensure_ascii=False)
                    ),
                }
            ],
            max_tokens=1000,
        )

        return _parse_json_response(content)

    except json.JSONDecodeError:
        logger.error("Failed to parse Claude recommendation response")
        return {"error": "AI cavabi emal edilmedi. Yeniden cehd edin."}
    except Exception as e:
        logger.error(f"Claude recommendation error: {e}")
        return {"error": "AI tovsiye ugursuz oldu. Yeniden cehd edin."}


TRAINER_VERIFICATION_PROMPT = """Sen tehlulesiz ve ciddi bir fitness ekspertisen. Bu sekil fitness muellimi (trainer) olmaq isteyen bir insana aiddir.

Cavabini YALNIZ JSON formatinda ver, baska hec ne yazma:
{
    "is_fitness_person": true,
    "confidence_score": 0.85,
    "analysis": "Detalli izahat (2-3 cumle)",
    "body_composition": "athletic",
    "visible_muscle_definition": true,
    "fitness_indicators": ["indicator1", "indicator2"],
    "red_flags": [],
    "photo_quality": "good"
}

CIDDI QAYDALAR:
1. REJECT (0.0-0.3): Sekilde insan yoxdur, selfie, screenshot, AI-generated, qrup sekli
2. LOW (0.3-0.5): Insan gorunur amma fitness ile elaqesi yoxdur
3. MEDIUM (0.5-0.75): Idman zalinda amma beden formasi orta
4. HIGH (0.75-1.0): Aciq-aydin atletik beden, ezele gorunur, professional
5. photo_quality: "excellent", "good", "acceptable", "poor", "invalid"
6. body_composition: "athletic", "fit", "average", "below_average"
7. Hemise AZ dilinde analiz yaz"""


def validate_image_basic(image_data: bytes) -> dict:
    """Pillow ile seklin keyfiyyetini yoxla"""
    issues = []
    quality_score = 1.0

    try:
        img = Image.open(io.BytesIO(image_data))
    except Exception:
        return {
            "is_valid": False,
            "width": 0, "height": 0,
            "aspect_ratio": 0,
            "file_size_kb": len(image_data) // 1024,
            "format": "unknown",
            "is_photo": False,
            "quality_score": 0.0,
            "issues": ["invalid_image_file"],
        }

    width, height = img.size
    file_size_kb = len(image_data) // 1024
    fmt = (img.format or "unknown").upper()
    aspect_ratio = round(width / max(height, 1), 2)

    if width < 200 or height < 200:
        issues.append("too_small")
        quality_score -= 0.4

    if file_size_kb < 10:
        issues.append("file_too_small")
        quality_score -= 0.3

    if fmt not in ("JPEG", "JPG", "PNG", "HEIC", "HEIF", "WEBP"):
        issues.append("unsupported_format")
        quality_score -= 0.2

    if aspect_ratio > 3.0 or aspect_ratio < 0.3:
        issues.append("unusual_aspect_ratio")
        quality_score -= 0.3

    try:
        small = img.resize((50, 50)).convert("RGB")
        pixels = list(small.getdata())
        unique_colors = len(set(pixels))

        if unique_colors < 50:
            issues.append("low_color_variety")
            quality_score -= 0.3

        from collections import Counter
        color_counts = Counter(pixels)
        most_common_count = color_counts.most_common(1)[0][1]
        if most_common_count > 2250:
            issues.append("mostly_solid_color")
            quality_score -= 0.5

    except Exception:
        pass

    if file_size_kb < 50 and width < 400:
        issues.append("likely_not_real_photo")
        quality_score -= 0.2

    is_photo = len(issues) == 0 or (len(issues) <= 1 and "likely_not_real_photo" not in issues)

    if 400 <= min(width, height) <= 800:
        quality_score = min(quality_score, 0.9)
    elif min(width, height) > 800:
        quality_score = min(quality_score, 1.0)

    quality_score = max(0.0, min(1.0, quality_score))

    return {
        "is_valid": quality_score > 0.2,
        "width": width,
        "height": height,
        "aspect_ratio": aspect_ratio,
        "file_size_kb": file_size_kb,
        "format": fmt,
        "is_photo": is_photo,
        "quality_score": round(quality_score, 2),
        "issues": issues,
    }


async def analyze_trainer_photo(image_data: bytes) -> dict:
    """Trainer-in fitness formasini analiz et — Claude Vision ile"""

    img_info = validate_image_basic(image_data)
    logger.info(f"Image validation: {img_info}")

    if not img_info["is_valid"]:
        return {
            "is_fitness_person": False,
            "confidence_score": 0.0,
            "analysis": f"Yuklenen sekil keyfiyyetsizdir. Problemler: {', '.join(img_info['issues'])}",
            "body_composition": "below_average",
            "visible_muscle_definition": False,
            "fitness_indicators": [],
            "red_flags": img_info["issues"],
            "photo_quality": "invalid",
            "image_validation": img_info,
        }

    if _has_valid_key:
        base64_image = base64.b64encode(image_data).decode("utf-8")

        try:
            content = await _call_claude(
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": TRAINER_VERIFICATION_PROMPT},
                            {
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": "image/jpeg",
                                    "data": base64_image,
                                },
                            },
                        ],
                    }
                ],
                max_tokens=1000,
            )

            ai_result = _parse_json_response(content)

            ai_score = ai_result.get("confidence_score", 0.0)
            img_quality = img_info["quality_score"]
            final_score = round(ai_score * 0.7 + img_quality * 0.3, 2)

            if not ai_result.get("is_fitness_person", False):
                final_score = min(final_score, 0.35)

            red_flags = ai_result.get("red_flags", [])
            if len(red_flags) >= 3:
                final_score = min(final_score, 0.40)
            elif len(red_flags) >= 1:
                final_score = max(0.0, final_score - 0.05 * len(red_flags))

            ai_result["confidence_score"] = final_score
            ai_result["image_validation"] = img_info
            return ai_result

        except json.JSONDecodeError:
            logger.error("Failed to parse Claude trainer analysis response")
            return {"error": "AI cavabi emal edilmedi. Yeniden cehd edin."}
        except Exception as e:
            logger.error(f"Claude trainer analysis error: {e}")
            return {"error": "AI analizi ugursuz oldu."}

    return _smart_mock_verification(img_info)


def _smart_mock_verification(img_info: dict) -> dict:
    """API key olmayanda Pillow analizi ile mock cavab"""
    quality = img_info["quality_score"]
    issues = img_info["issues"]

    if quality < 0.3 or "invalid_image_file" in issues or "mostly_solid_color" in issues:
        return {
            "is_fitness_person": False,
            "confidence_score": 0.10,
            "analysis": "Sekil keyfiyyeti cox asagidir. Aydin fitness sekli yukleyin.",
            "body_composition": "below_average",
            "visible_muscle_definition": False,
            "fitness_indicators": [],
            "red_flags": issues,
            "photo_quality": "invalid",
            "image_validation": img_info,
            "is_mock": True,
            "requires_manual_review": True,
        }

    if quality < 0.7 or len(issues) >= 2:
        return {
            "is_fitness_person": False,
            "confidence_score": 0.35,
            "analysis": "Sekil yuklendi, keyfiyyet yaxsilasdirilmalidir. Admin yoxlayacaq.",
            "body_composition": "average",
            "visible_muscle_definition": False,
            "fitness_indicators": [],
            "red_flags": issues if issues else ["ai_unavailable"],
            "photo_quality": "poor",
            "image_validation": img_info,
            "is_mock": True,
            "requires_manual_review": True,
        }

    return {
        "is_fitness_person": True,
        "confidence_score": 0.60,
        "analysis": "Sekil keyfiyyeti yaxsidir. Admin terefinden manual yoxlanilacaq.",
        "body_composition": "average",
        "visible_muscle_definition": False,
        "fitness_indicators": [],
        "red_flags": ["ai_unavailable"],
        "photo_quality": "good",
        "image_validation": img_info,
        "is_mock": True,
        "requires_manual_review": True,
    }


def _mock_analysis() -> dict:
    """API key olmayanda mock cavab"""
    return {
        "foods": [
            {
                "name": "Test yemek (AI key yoxdur)",
                "calories": 350,
                "protein": 25.0,
                "carbs": 40.0,
                "fats": 10.0,
                "portion_size": "1 porsia (250g)",
            }
        ],
        "total_calories": 350,
        "total_protein": 25.0,
        "total_carbs": 40.0,
        "total_fats": 10.0,
        "meal_type": "lunch",
        "confidence": 0.0,
        "notes": "Mock cavab. .env-de ANTHROPIC_API_KEY teyin edin.",
        "is_mock": True,
    }


def _mock_recommendations() -> dict:
    """API key olmayanda mock tovsiyeler"""
    return {
        "summary": "Mock tovsiye. .env-de ANTHROPIC_API_KEY teyin edin.",
        "nutrition_tips": [
            "Gunde 2L su icin",
            "Protein miqdarini artirin",
            "Sebze-meyveni unutmayin",
        ],
        "workout_tips": [
            "Heftelik 3-4 defe mesq edin",
            "Kardio ve guc mesqlerini birlesdirin",
            "Istirahete vaxt ayirin",
        ],
        "warnings": [],
        "weekly_score": 50,
        "is_mock": True,
    }
