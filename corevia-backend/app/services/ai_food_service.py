"""
AI Food Analysis Service - OpenAI Vision API Integration

Analyzes food images using OpenAI GPT-4 Vision to extract:
- Food name
- Calories
- Protein, Carbs, Fats
- Portion size estimation
"""

import base64
import json
import logging
from typing import Dict, Optional
from openai import AsyncOpenAI
from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class AIFoodService:
    """
    OpenAI Vision-based food analysis service
    """

    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = "gpt-4o-mini"  # Faster and cheaper than gpt-4o

    async def analyze_food_image(
        self,
        image_base64: str,
        language: str = "az"  # az, en, tr, ru
    ) -> Dict:
        """
        Analyze food image and return nutritional information

        Args:
            image_base64: Base64 encoded image string
            language: Response language (az=Azerbaijani, en=English, tr=Turkish, ru=Russian)

        Returns:
            {
                "success": bool,
                "food_name": str,
                "calories": int,
                "protein": float,
                "carbs": float,
                "fats": float,
                "portion_size": str,
                "confidence": float,  # 0.0 - 1.0
                "error": str (optional)
            }
        """

        if not settings.openai_api_key or settings.openai_api_key == "your-openai-api-key-here":
            logger.warning("OpenAI API key not configured, using mock data")
            return self._mock_analysis()

        try:
            # Language-specific prompts
            prompts = {
                "az": """Şəkildəki qidanı təhlil et və aşağıdakı JSON formatında cavab ver:
{
  "food_name": "qida adı (azərbaycanca)",
  "calories": kalori miqdarı (tam ədəd),
  "protein": protein qramla (onluq),
  "carbs": karbohidrat qramla (onluq),
  "fats": yağ qramla (onluq),
  "portion_size": "təxmini porsiya ölçüsü",
  "confidence": 0.0-1.0 arası inam dərəcəsi
}

Əgər şəkildə qida görünmürsə və ya təhlil mümkün deyilsə, confidence: 0.0 qaytar.""",

                "en": """Analyze the food in the image and respond in this JSON format:
{
  "food_name": "food name (in English)",
  "calories": calorie count (integer),
  "protein": protein in grams (decimal),
  "carbs": carbohydrates in grams (decimal),
  "fats": fat in grams (decimal),
  "portion_size": "approximate portion size",
  "confidence": confidence level 0.0-1.0
}

If no food is visible or analysis is not possible, return confidence: 0.0.""",

                "tr": """Resimdeki yiyeceği analiz et ve şu JSON formatında yanıt ver:
{
  "food_name": "yemek adı (Türkçe)",
  "calories": kalori miktarı (tam sayı),
  "protein": protein gram olarak (ondalık),
  "carbs": karbonhidrat gram olarak (ondalık),
  "fats": yağ gram olarak (ondalık),
  "portion_size": "yaklaşık porsiyon boyutu",
  "confidence": 0.0-1.0 arası güven seviyesi
}

Eğer resimde yemek görünmüyorsa veya analiz mümkün değilse, confidence: 0.0 döndür.""",

                "ru": """Проанализируй еду на изображении и ответь в формате JSON:
{
  "food_name": "название блюда (на русском)",
  "calories": количество калорий (целое число),
  "protein": белок в граммах (десятичное),
  "carbs": углеводы в граммах (десятичное),
  "fats": жиры в граммах (десятичное),
  "portion_size": "примерный размер порции",
  "confidence": уровень уверенности 0.0-1.0
}

Если еда не видна или анализ невозможен, верни confidence: 0.0."""
            }

            prompt = prompts.get(language, prompts["az"])

            # Call OpenAI Vision API
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": prompt},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{image_base64}",
                                    "detail": "low"  # Faster and cheaper
                                }
                            }
                        ]
                    }
                ],
                max_tokens=300,
                temperature=0.3,  # Lower = more consistent results
            )

            # Parse response
            content = response.choices[0].message.content.strip()

            # Extract JSON from response (handle markdown code blocks)
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            result = json.loads(content)

            # Validate result
            if result.get("confidence", 0) < 0.3:
                return {
                    "success": False,
                    "error": "Şəkildə qida aşkar edilmədi və ya analiz etmək mümkün olmadı."
                }

            return {
                "success": True,
                "food_name": result.get("food_name", "Naməlum Qida"),
                "calories": int(result.get("calories", 0)),
                "protein": float(result.get("protein", 0.0)),
                "carbs": float(result.get("carbs", 0.0)),
                "fats": float(result.get("fats", 0.0)),
                "portion_size": result.get("portion_size", "Standart"),
                "confidence": float(result.get("confidence", 0.0))
            }

        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse OpenAI response: {e}")
            return {
                "success": False,
                "error": "AI cavabı emal edilmədi. Yenidən cəhd edin."
            }

        except Exception as e:
            logger.error(f"AI food analysis error: {e}")
            return {
                "success": False,
                "error": f"AI analizi uğursuz oldu: {str(e)}"
            }

    def _mock_analysis(self) -> Dict:
        """Mock analysis for testing without OpenAI API key"""
        import random

        mock_foods = [
            {"name": "Plov", "cal": 450, "p": 18.0, "c": 55.0, "f": 15.0, "portion": "1 boşqab"},
            {"name": "Düşbərə", "cal": 320, "p": 22.0, "c": 38.0, "f": 9.0, "portion": "1 kasa"},
            {"name": "Qutab", "cal": 280, "p": 12.0, "c": 35.0, "f": 11.0, "portion": "2 ədəd"},
            {"name": "Balıq Kebabı", "cal": 350, "p": 38.0, "c": 5.0, "f": 18.0, "portion": "1 porsiya"},
            {"name": "Salat", "cal": 120, "p": 4.0, "c": 12.0, "f": 6.0, "portion": "1 qab"},
        ]

        food = random.choice(mock_foods)

        logger.info("🔶 MOCK MODE: AI Food Analysis using random data")

        return {
            "success": True,
            "food_name": food["name"],
            "calories": food["cal"],
            "protein": food["p"],
            "carbs": food["c"],
            "fats": food["f"],
            "portion_size": food["portion"],
            "confidence": 0.85
        }


# Singleton instance
ai_food_service = AIFoodService()
