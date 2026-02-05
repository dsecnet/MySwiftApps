import json
import base64
import io
import logging
from PIL import Image
from openai import AsyncOpenAI
from app.config import get_settings

logger = logging.getLogger(__name__)

settings = get_settings()

_has_valid_key = settings.openai_api_key and not settings.openai_api_key.startswith("your-")
client = AsyncOpenAI(api_key=settings.openai_api_key) if _has_valid_key else None

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
- Hemise AZ dilde cavab ver"""


async def analyze_food_image(image_data: bytes) -> dict:
    """OpenAI Vision API ile sekildeki yemekleri analiz et"""
    if not client:
        return _mock_analysis()

    base64_image = base64.b64encode(image_data).decode("utf-8")

    try:
        response = await client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": FOOD_ANALYSIS_PROMPT},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                                "detail": "low",
                            },
                        },
                    ],
                }
            ],
            max_tokens=1000,
            temperature=0.3,
        )

        content = response.choices[0].message.content.strip()

        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            content = content.rsplit("```", 1)[0]

        return json.loads(content)

    except json.JSONDecodeError:
        return {"error": "AI cavabi parse oluna bilmedi", "raw": content}
    except Exception as e:
        return {"error": str(e)}


RECOMMENDATION_PROMPT = """Sen bir fitness ve qidalanma mütexessisisen. Asagidaki istifadeci melumatlarini analiz et ve ona sexsi tovsiyeler ver.

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
    if not client:
        return _mock_recommendations()

    try:
        response = await client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": RECOMMENDATION_PROMPT.format(user_data=json.dumps(user_data, ensure_ascii=False)),
                }
            ],
            max_tokens=1000,
            temperature=0.5,
        )

        content = response.choices[0].message.content.strip()
        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            content = content.rsplit("```", 1)[0]

        return json.loads(content)

    except json.JSONDecodeError:
        return {"error": "AI cavabi parse oluna bilmedi", "raw": content}
    except Exception as e:
        return {"error": str(e)}


TRAINER_VERIFICATION_PROMPT = """Sen tehlulesiz ve ciddi bir fitness ekspertisen. Bu sekil fitness muellimi (trainer) olmaq isteyen bir insana aiddir.

SENI CIDDI QIYMETLENDIRME ETMEYE CAGIRIRIQ. Yalniz REAL fitness insanlarini tesdiqle.

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

1. REJECT (confidence_score 0.0-0.3) - asagidaki hallarda:
   - Sekilde insan yoxdur (heyvan, manzara, yemek, obyekt, meme, screenshot)
   - Insanin uzU/bedeni gorunmur (arxadan cekilmis, qaranlig, bulanik)
   - Selfie ve ya sadece sifet sekli (beden formasi gorunmur)
   - Sekil internet-den goturulib (watermark, stock photo nishanlari)
   - Cizgi film, photoshop, AI-generated sekil
   - Qrup sekli (kim oldugu belli deyil)
   - Ekran goruntusu (screenshot)

2. LOW SCORE (confidence_score 0.3-0.5) - asagidaki hallarda:
   - Insan gorunur amma fitness ile elaqesi yoxdur
   - Normal geyimde, evde/kucede adi sekil
   - Fiziki forma orta ve ya orta-asagi
   - Hec bir fitness gostericisi yoxdur

3. MEDIUM SCORE (confidence_score 0.5-0.75) - asagidaki hallarda:
   - Idman zalinda sekil amma beden formasi orta
   - Idman geyiminde amma fiziki forma bilinmir
   - Fit gorunur amma trainer seviyyesinde deyil

4. HIGH SCORE (confidence_score 0.75-1.0) - YALNIZ asagidaki hallarda:
   - Aciq-aydin atletik beden qurulusu gorunur
   - Ezele qurulusu gorunur (qol, kol, qarin, ayaq)
   - Idman zali muhitinde ve ya idman geyiminde
   - Professional fitness fotosuna benzeyir
   - Beden formasi trainer seviyyesindedir

5. photo_quality: "excellent", "good", "acceptable", "poor", "invalid" birini sec
6. red_flags: su hallarin siyahisi: ["no_person", "face_only", "blurry", "screenshot", "stock_photo", "ai_generated", "group_photo", "no_fitness_indicators", "poor_lighting"]
7. body_composition: "athletic", "fit", "average", "below_average" birini sec
8. fitness_indicators: gozle gorunen fitness gostericileri siyahisi
9. Hemise AZ dilinde analiz yaz

DIQGET: Yalniz insanin BEDEN FORMASI gorunurse yuksek score ver. Eger seklin keyfiyyeti asagi olarsa ve ya beden formasi aydın deyilse, ASAGI score ver."""


def validate_image_basic(image_data: bytes) -> dict:
    """Pillow ile seklin keyfiyyetini ve esasligini yoxla.

    Qaytarir:
        {
            "is_valid": bool,
            "width": int,
            "height": int,
            "aspect_ratio": float,
            "file_size_kb": int,
            "format": str,
            "is_photo": bool,        # Real foto yoxsa cizgi/screenshot?
            "quality_score": float,   # 0.0-1.0
            "issues": [str],
        }
    """
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

    # 1. Minimum olcu yoxlamasi — cox kicik sekiller reject olunur
    if width < 200 or height < 200:
        issues.append("too_small")
        quality_score -= 0.4

    # 2. Minimum file size — cox kicik fayl (< 10KB) screenshot ve ya icon ola biler
    if file_size_kb < 10:
        issues.append("file_too_small")
        quality_score -= 0.3

    # 3. Format yoxlamasi
    if fmt not in ("JPEG", "JPG", "PNG", "HEIC", "HEIF", "WEBP"):
        issues.append("unsupported_format")
        quality_score -= 0.2

    # 4. Cox uzun/ensiz aspect ratio — banner, panorama, screenshot
    if aspect_ratio > 3.0 or aspect_ratio < 0.3:
        issues.append("unusual_aspect_ratio")
        quality_score -= 0.3

    # 5. Renq analizi — tamam bir reng, screenshot/blank
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
        if most_common_count > 2250:  # 90% of 2500
            issues.append("mostly_solid_color")
            quality_score -= 0.5

    except Exception:
        pass  # Renq analizi ugursuz olsa kecirik

    # 6. Sekil coxmu kicikdir (real foto adeten 100KB+)
    if file_size_kb < 50 and width < 400:
        issues.append("likely_not_real_photo")
        quality_score -= 0.2

    # 7. Yaxsi keyfiyyet gostericileri
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
    """Trainer-in fitness formasini analiz et.

    1. Evvelce Pillow ile sekil keyfiyyetini yoxla
    2. OpenAI key varsa — GPT-4 Vision ile detalli analiz
    3. OpenAI key yoxdursa — yalniz image validation neticesini qaytarir
    """

    img_info = validate_image_basic(image_data)
    logger.info(f"Image validation: {img_info}")

    if not img_info["is_valid"]:
        return {
            "is_fitness_person": False,
            "confidence_score": 0.0,
            "analysis": f"Yüklənən şəkil keyfiyyətsizdir. Problemlər: {', '.join(img_info['issues'])}",
            "body_composition": "below_average",
            "visible_muscle_definition": False,
            "fitness_indicators": [],
            "red_flags": img_info["issues"],
            "photo_quality": "invalid",
            "image_validation": img_info,
        }

    if client:
        base64_image = base64.b64encode(image_data).decode("utf-8")

        try:
            response = await client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": TRAINER_VERIFICATION_PROMPT},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{base64_image}",
                                    "detail": "high",
                                },
                            },
                        ],
                    }
                ],
                max_tokens=1000,
                temperature=0.2,
            )

            content = response.choices[0].message.content.strip()

            if content.startswith("```"):
                content = content.split("\n", 1)[1]
                content = content.rsplit("```", 1)[0]

            ai_result = json.loads(content)

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
            return {"error": "AI cavabi parse oluna bilmedi", "raw": content}
        except Exception as e:
            return {"error": str(e)}

    return _smart_mock_verification(img_info)


def _smart_mock_verification(img_info: dict) -> dict:
    """OpenAI key olmayanda Pillow analizi ile ağıllı mock cavab.

    Seklin keyfiyyetine gore score verir:
    - Yaxsi keyfiyyetli, boyuk, real foto → 0.60 (pending — admin yoxlasin)
    - Orta keyfiyyet → 0.45 (pending/rejected zone)
    - Pis keyfiyyet → 0.15 (rejected)

    HEVAXT avtomatik verified (0.80+) vermir — OpenAI olmadan
    yalniz admin manual tesdiq ede biler.
    """
    quality = img_info["quality_score"]
    issues = img_info["issues"]

    if quality < 0.3 or "invalid_image_file" in issues or "mostly_solid_color" in issues:
        return {
            "is_fitness_person": False,
            "confidence_score": 0.10,
            "analysis": "Şəkil keyfiyyəti çox aşağıdır və ya düzgün yüklənməyib. Zəhmət olmasa aydın fitness şəkli yükləyin.",
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
            "analysis": "Şəkil yükləndi, lakin keyfiyyət yaxşılaşdırılmalıdır. Admin tərəfindən yoxlanılacaq.",
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
        "analysis": "Şəkil keyfiyyəti yaxşıdır. AI analizi mövcud olmadığı üçün admin tərəfindən manual yoxlanılacaq.",
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
    """OpenAI key olmayanda test ucun mock cavab"""
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
        "notes": "Bu mock cavabdir. .env faylinda OPENAI_API_KEY teyin edin.",
        "is_mock": True,
    }


def _mock_recommendations() -> dict:
    """OpenAI key olmayanda test ucun mock tovsiyeler"""
    return {
        "summary": "Bu mock tovsiyedir. .env faylinda OPENAI_API_KEY teyin edin.",
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
