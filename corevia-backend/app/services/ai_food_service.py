"""
AI Food Analysis Service - Anthropic Claude Vision API Integration

Analyzes food images using Claude Sonnet Vision to extract:
- Food name
- Calories
- Protein, Carbs, Fats
- Portion size estimation

Claude Vision daha deqiq neticeler verir, xususen Azerbaycan yemeleri ucun.
"""

import base64
import json
import logging
from typing import Dict
import httpx
from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class AIFoodService:
    """
    Anthropic Claude Vision-based food analysis service
    """

    def __init__(self):
        self.api_key = settings.anthropic_api_key
        self.model = "claude-sonnet-4-20250514"
        self.api_url = "https://api.anthropic.com/v1/messages"
        self._has_valid_key = bool(
            self.api_key
            and not self.api_key.startswith("your-")
            and len(self.api_key) > 20
        )

    async def analyze_food_image(
        self,
        image_base64: str,
        language: str = "az",
        media_type: str = "image/jpeg"
    ) -> Dict:
        """
        Analyze food image and return nutritional information
        """

        if not self._has_valid_key:
            logger.warning("Anthropic API key not configured, using mock data")
            return self._mock_analysis()

        try:
            prompts = {
                "az": """Sekildeki qidani tehlil et. Eger sekilde qida gorunmurse, confidence: 0.0 qaytar.

YALNIZ bu JSON formatinda cavab ver, basqa hec ne yazma:
{
  "food_name": "qida adi (azerbaycanca)",
  "calories": kalori miqdari (tam eded),
  "protein": protein qramla (onluq),
  "carbs": karbohidrat qramla (onluq),
  "fats": yag qramla (onluq),
  "portion_size": "texmini porsiya olcusu (qram ile)",
  "confidence": 0.0-1.0 arasi inam derecesi
}

Qaydalar:
- Kalori ve makrolari porsiya olcusune gore hesabla
- Azerbaycan yemeklerini (plov, dolma, qutab, dusbere, dovga, lulekebab ve s.) deqiq tani
- Porsiya olcusunu qram ile goster (mes: "1 bosqab (~350g)")
- Eger bir nece yemek varsa, hamisini birlikde hesabla
- Eger sekil bulaniq ve ya qida deyilse, confidence asagi olsun""",

                "en": """Analyze the food in the image. If no food is visible, return confidence: 0.0.

Respond ONLY with this JSON format, nothing else:
{
  "food_name": "food name",
  "calories": calorie count (integer),
  "protein": protein in grams (decimal),
  "carbs": carbohydrates in grams (decimal),
  "fats": fat in grams (decimal),
  "portion_size": "approximate portion size with grams",
  "confidence": confidence level 0.0-1.0
}""",

                "tr": """Resimdeki yiyecegi analiz et. Yemek yoksa confidence: 0.0 dondur.

YALNIZCA bu JSON formatinda yanit ver:
{
  "food_name": "yemek adi (Turkce)",
  "calories": kalori miktari (tam sayi),
  "protein": protein gram (ondalik),
  "carbs": karbonhidrat gram (ondalik),
  "fats": yag gram (ondalik),
  "portion_size": "yaklasik porsiyon boyutu (gram ile)",
  "confidence": 0.0-1.0 arasi guven seviyesi
}""",

                "ru": """Proanaliziruj edu na izobrazhenii. Esli eda ne vidna, verni confidence: 0.0.

Otvet TOLKO v etom JSON formate:
{
  "food_name": "nazvanie blyuda (na russkom)",
  "calories": kolichestvo kalorij (celoe chislo),
  "protein": belok v grammah (desyatichnoe),
  "carbs": uglevody v grammah (desyatichnoe),
  "fats": zhiry v grammah (desyatichnoe),
  "portion_size": "primernyj razmer porcii (v grammah)",
  "confidence": uroven uverennosti 0.0-1.0
}"""
            }

            prompt = prompts.get(language, prompts["az"])

            if media_type not in ("image/jpeg", "image/png", "image/gif", "image/webp"):
                media_type = "image/jpeg"

            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    self.api_url,
                    headers={
                        "x-api-key": self.api_key,
                        "anthropic-version": "2023-06-01",
                        "content-type": "application/json",
                    },
                    json={
                        "model": self.model,
                        "max_tokens": 500,
                        "messages": [
                            {
                                "role": "user",
                                "content": [
                                    {
                                        "type": "image",
                                        "source": {
                                            "type": "base64",
                                            "media_type": media_type,
                                            "data": image_base64,
                                        }
                                    },
                                    {
                                        "type": "text",
                                        "text": prompt,
                                    }
                                ]
                            }
                        ]
                    }
                )

            if response.status_code != 200:
                error_text = response.text[:300]
                logger.error(f"Anthropic API error {response.status_code}: {error_text}")

                # Kredit balansı problemi
                if "credit balance" in error_text.lower() or "billing" in error_text.lower():
                    return {
                        "success": False,
                        "error": "AI xidməti müvəqqəti əlçatmazdır. Zəhmət olmasa sonra yenidən cəhd edin."
                    }

                return {
                    "success": False,
                    "error": f"AI servisi cavab vermedi (status: {response.status_code})"
                }

            data = response.json()
            content = data["content"][0]["text"].strip()

            # Extract JSON from markdown code blocks
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            result = json.loads(content)

            confidence = float(result.get("confidence", 0))
            if confidence < 0.3:
                return {
                    "success": False,
                    "error": "Sekilde qida askar edilmedi ve ya analiz etmek mumkun olmadi."
                }

            return {
                "success": True,
                "food_name": result.get("food_name", "Namelum Qida"),
                "calories": int(result.get("calories", 0)),
                "protein": round(float(result.get("protein", 0.0)), 1),
                "carbs": round(float(result.get("carbs", 0.0)), 1),
                "fats": round(float(result.get("fats", 0.0)), 1),
                "portion_size": result.get("portion_size", "Standart"),
                "confidence": round(confidence, 2)
            }

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse Claude response: {e}")
            return {
                "success": False,
                "error": "AI cavabi emal edilmedi. Yeniden cehd edin."
            }

        except httpx.TimeoutException:
            logger.error("Anthropic API timeout")
            return {
                "success": False,
                "error": "AI servisi cavab vermedi. Yeniden cehd edin."
            }

        except Exception as e:
            logger.error(f"AI food analysis error: {e}")
            return {
                "success": False,
                "error": "AI analizi ugursuz oldu. Yeniden cehd edin."
            }

    def _mock_analysis(self) -> Dict:
        """Mock analysis for testing without API key"""
        import random

        mock_foods = [
            {"name": "Plov", "cal": 450, "p": 18.0, "c": 55.0, "f": 15.0, "portion": "1 bosqab (~350g)"},
            {"name": "Dusbere", "cal": 320, "p": 22.0, "c": 38.0, "f": 9.0, "portion": "1 kasa (~300g)"},
            {"name": "Qutab (et)", "cal": 280, "p": 12.0, "c": 35.0, "f": 11.0, "portion": "2 eded (~200g)"},
            {"name": "Lule kebab", "cal": 350, "p": 38.0, "c": 5.0, "f": 18.0, "portion": "1 porsiya (~250g)"},
            {"name": "Salat", "cal": 120, "p": 4.0, "c": 12.0, "f": 6.0, "portion": "1 qab (~200g)"},
        ]

        food = random.choice(mock_foods)
        logger.info("MOCK MODE: AI Food Analysis (API key not set)")

        return {
            "success": True,
            "food_name": food["name"],
            "calories": food["cal"],
            "protein": food["p"],
            "carbs": food["c"],
            "fats": food["f"],
            "portion_size": food["portion"],
            "confidence": 0.85,
            "is_mock": True
        }


# Singleton instance
ai_food_service = AIFoodService()
