import json
import base64
from openai import AsyncOpenAI
from app.config import get_settings

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

        # JSON parse et (bazen ```json ... ``` ile qaytarir)
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


TRAINER_VERIFICATION_PROMPT = """Sen bir fitness ekspertisen. Bu sekildeki insanin beden formasini ve fiziki hazirligini qiymetlendir.

Bu insan fitness muellimi (trainer) olmaq ucun muraciet edir. Onun beden formasi ve fiziki gorunusu esasinda qiymetlendir.

Cavabini YALNIZ JSON formatinda ver, baska hec ne yazma:
{
    "is_fitness_person": true,
    "confidence_score": 0.85,
    "analysis": "Qisa izahat (1-2 cumle)",
    "body_composition": "athletic",
    "visible_muscle_definition": true,
    "fitness_indicators": ["indicator1", "indicator2"]
}

Qaydalar:
- is_fitness_person: bu insanin fitness muellimi ola bileceyine inanirsan?
- confidence_score: 0.0-1.0 arasi (ne qeder eminsen)
- body_composition: "athletic", "fit", "average", "below_average" birini sec
- visible_muscle_definition: ezele qurulusu gorunurmu?
- fitness_indicators: gozle gorunen fitness gostericileri (meselen: "guclu qol ezelesi", "duz qarin", "idmanci beden qurulusu")
- Eger sekilde insan yoxdursa ve ya aydın deyilse, confidence_score 0 olsun
- Hemise AZ dilinde cavab ver"""


async def analyze_trainer_photo(image_data: bytes) -> dict:
    """OpenAI Vision API ile trainer-in fitness formasini analiz et"""
    if not client:
        return _mock_trainer_verification()

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
                                "detail": "low",
                            },
                        },
                    ],
                }
            ],
            max_tokens=800,
            temperature=0.3,
        )

        content = response.choices[0].message.content.strip()

        # JSON parse et
        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            content = content.rsplit("```", 1)[0]

        return json.loads(content)

    except json.JSONDecodeError:
        return {"error": "AI cavabi parse oluna bilmedi", "raw": content}
    except Exception as e:
        return {"error": str(e)}


def _mock_trainer_verification() -> dict:
    """OpenAI key olmayanda test ucun mock trainer verification cavabi"""
    return {
        "is_fitness_person": True,
        "confidence_score": 0.65,
        "analysis": "Mock cavab: AI key yoxdur. Test ucun orta skor qaytarilir.",
        "body_composition": "fit",
        "visible_muscle_definition": False,
        "fitness_indicators": ["normal beden qurulusu"],
        "is_mock": True,
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
