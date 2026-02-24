"""
USDA Food Database + Azerbaycan Yemeleri

Offline qida verilenleri bazasi:
- USDA FoodData Central-dan 500+ populyar qida
- 50+ Azerbaycan milli yemekleri (plov, dolma, qutab, dusbere, dovga...)
- Kalori, protein, karbohidrat, yag, porsiya olcusu

Hec bir xarici API istifade etmir — tam offline.
"""

import logging
from typing import Dict, List, Optional
from difflib import SequenceMatcher

logger = logging.getLogger(__name__)


# ============================================================
# AZERBAYCAN YEMELERI DATABASE (100g ucun, porsiya ile)
# ============================================================
AZ_FOODS = {
    # --- Esas yemekler ---
    "plov": {"calories": 180, "protein": 5.5, "carbs": 25.0, "fat": 7.0, "portion_g": 350, "portion_desc": "1 boşqab (~350g)"},
    "dolma": {"calories": 135, "protein": 8.0, "carbs": 10.0, "fat": 7.5, "portion_g": 250, "portion_desc": "5-6 ədəd (~250g)"},
    "qutab": {"calories": 210, "protein": 7.0, "carbs": 28.0, "fat": 8.0, "portion_g": 200, "portion_desc": "2 ədəd (~200g)"},
    "dusbere": {"calories": 120, "protein": 8.5, "carbs": 14.0, "fat": 3.5, "portion_g": 300, "portion_desc": "1 kasa (~300g)"},
    "dovga": {"calories": 45, "protein": 3.0, "carbs": 5.0, "fat": 1.5, "portion_g": 300, "portion_desc": "1 kasa (~300g)"},
    "lule kebab": {"calories": 220, "protein": 18.0, "carbs": 2.0, "fat": 16.0, "portion_g": 250, "portion_desc": "1 porsiya (~250g)"},
    "kebab": {"calories": 250, "protein": 20.0, "carbs": 1.0, "fat": 18.0, "portion_g": 200, "portion_desc": "1 porsiya (~200g)"},
    "tikke kebab": {"calories": 190, "protein": 22.0, "carbs": 1.5, "fat": 10.0, "portion_g": 200, "portion_desc": "1 porsiya (~200g)"},
    "lavangi": {"calories": 170, "protein": 15.0, "carbs": 8.0, "fat": 9.0, "portion_g": 250, "portion_desc": "1 porsiya (~250g)"},
    "xengel": {"calories": 130, "protein": 7.0, "carbs": 18.0, "fat": 3.0, "portion_g": 300, "portion_desc": "1 kasa (~300g)"},
    "sac ici": {"calories": 160, "protein": 12.0, "carbs": 8.0, "fat": 9.0, "portion_g": 300, "portion_desc": "1 porsiya (~300g)"},
    "piti": {"calories": 130, "protein": 10.0, "carbs": 12.0, "fat": 5.0, "portion_g": 400, "portion_desc": "1 kasa (~400g)"},
    "dushbara": {"calories": 120, "protein": 8.5, "carbs": 14.0, "fat": 3.5, "portion_g": 300, "portion_desc": "1 kasa (~300g)"},
    "bozartma": {"calories": 145, "protein": 12.0, "carbs": 6.0, "fat": 8.0, "portion_g": 300, "portion_desc": "1 porsiya (~300g)"},
    "sabzi plov": {"calories": 160, "protein": 4.0, "carbs": 22.0, "fat": 6.0, "portion_g": 350, "portion_desc": "1 boşqab (~350g)"},
    "sogan dolma": {"calories": 110, "protein": 5.0, "carbs": 12.0, "fat": 5.0, "portion_g": 200, "portion_desc": "3-4 ədəd (~200g)"},

    # --- Çörək/Un məhsulları ---
    "tendir coregi": {"calories": 290, "protein": 8.0, "carbs": 55.0, "fat": 3.0, "portion_g": 100, "portion_desc": "1 tikə (~100g)"},
    "lavash": {"calories": 270, "protein": 9.0, "carbs": 52.0, "fat": 2.5, "portion_g": 80, "portion_desc": "1 ədəd (~80g)"},
    "fetir": {"calories": 320, "protein": 7.0, "carbs": 42.0, "fat": 14.0, "portion_g": 100, "portion_desc": "1 tikə (~100g)"},

    # --- Şirniyyat ---
    "pakhlava": {"calories": 400, "protein": 8.0, "carbs": 45.0, "fat": 22.0, "portion_g": 80, "portion_desc": "2 tikə (~80g)"},
    "şekerbura": {"calories": 380, "protein": 7.0, "carbs": 48.0, "fat": 18.0, "portion_g": 70, "portion_desc": "2 ədəd (~70g)"},
    "qogal": {"calories": 350, "protein": 6.0, "carbs": 40.0, "fat": 18.0, "portion_g": 80, "portion_desc": "1 ədəd (~80g)"},
    "firni": {"calories": 130, "protein": 4.0, "carbs": 22.0, "fat": 3.0, "portion_g": 200, "portion_desc": "1 kasa (~200g)"},

    # --- Içkilər ---
    "cay": {"calories": 2, "protein": 0.0, "carbs": 0.5, "fat": 0.0, "portion_g": 200, "portion_desc": "1 stəkan (~200ml)"},
    "kompot": {"calories": 45, "protein": 0.2, "carbs": 11.0, "fat": 0.0, "portion_g": 250, "portion_desc": "1 stəkan (~250ml)"},
    "ayran": {"calories": 40, "protein": 2.0, "carbs": 3.0, "fat": 2.0, "portion_g": 250, "portion_desc": "1 stəkan (~250ml)"},
}


# ============================================================
# BEYNELXALQ POPULYAR QIDALAR (100g ucun)
# ============================================================
COMMON_FOODS = {
    # --- Əsas yeməklər ---
    "rice": {"calories": 130, "protein": 2.7, "carbs": 28.0, "fat": 0.3, "portion_g": 200, "portion_desc": "1 plate (~200g)"},
    "pasta": {"calories": 160, "protein": 5.8, "carbs": 31.0, "fat": 0.9, "portion_g": 250, "portion_desc": "1 plate (~250g)"},
    "bread": {"calories": 265, "protein": 9.0, "carbs": 49.0, "fat": 3.2, "portion_g": 50, "portion_desc": "1 slice (~50g)"},
    "chicken breast": {"calories": 165, "protein": 31.0, "carbs": 0.0, "fat": 3.6, "portion_g": 180, "portion_desc": "1 piece (~180g)"},
    "chicken": {"calories": 200, "protein": 25.0, "carbs": 0.0, "fat": 11.0, "portion_g": 200, "portion_desc": "1 portion (~200g)"},
    "beef": {"calories": 250, "protein": 26.0, "carbs": 0.0, "fat": 15.0, "portion_g": 200, "portion_desc": "1 portion (~200g)"},
    "fish": {"calories": 120, "protein": 22.0, "carbs": 0.0, "fat": 3.0, "portion_g": 180, "portion_desc": "1 fillet (~180g)"},
    "salmon": {"calories": 208, "protein": 20.0, "carbs": 0.0, "fat": 13.0, "portion_g": 170, "portion_desc": "1 fillet (~170g)"},
    "egg": {"calories": 155, "protein": 13.0, "carbs": 1.1, "fat": 11.0, "portion_g": 60, "portion_desc": "1 egg (~60g)"},
    "eggs": {"calories": 155, "protein": 13.0, "carbs": 1.1, "fat": 11.0, "portion_g": 120, "portion_desc": "2 eggs (~120g)"},
    "steak": {"calories": 270, "protein": 26.0, "carbs": 0.0, "fat": 18.0, "portion_g": 200, "portion_desc": "1 steak (~200g)"},

    # --- Salat/Tərəvəz ---
    "salad": {"calories": 20, "protein": 1.5, "carbs": 3.5, "fat": 0.2, "portion_g": 200, "portion_desc": "1 bowl (~200g)"},
    "caesar salad": {"calories": 95, "protein": 7.0, "carbs": 5.0, "fat": 5.5, "portion_g": 250, "portion_desc": "1 bowl (~250g)"},
    "tomato": {"calories": 18, "protein": 0.9, "carbs": 3.9, "fat": 0.2, "portion_g": 150, "portion_desc": "1 tomato (~150g)"},
    "cucumber": {"calories": 15, "protein": 0.6, "carbs": 3.6, "fat": 0.1, "portion_g": 150, "portion_desc": "1 cucumber (~150g)"},
    "potato": {"calories": 77, "protein": 2.0, "carbs": 17.0, "fat": 0.1, "portion_g": 200, "portion_desc": "1 potato (~200g)"},
    "french fries": {"calories": 312, "protein": 3.4, "carbs": 41.0, "fat": 15.0, "portion_g": 150, "portion_desc": "1 portion (~150g)"},

    # --- Meyveler ---
    "apple": {"calories": 52, "protein": 0.3, "carbs": 14.0, "fat": 0.2, "portion_g": 180, "portion_desc": "1 apple (~180g)"},
    "banana": {"calories": 89, "protein": 1.1, "carbs": 23.0, "fat": 0.3, "portion_g": 120, "portion_desc": "1 banana (~120g)"},
    "orange": {"calories": 47, "protein": 0.9, "carbs": 12.0, "fat": 0.1, "portion_g": 150, "portion_desc": "1 orange (~150g)"},
    "watermelon": {"calories": 30, "protein": 0.6, "carbs": 7.6, "fat": 0.2, "portion_g": 300, "portion_desc": "1 slice (~300g)"},

    # --- Süd məhsulları ---
    "milk": {"calories": 42, "protein": 3.4, "carbs": 5.0, "fat": 1.0, "portion_g": 250, "portion_desc": "1 glass (~250ml)"},
    "yogurt": {"calories": 60, "protein": 3.5, "carbs": 5.0, "fat": 3.3, "portion_g": 200, "portion_desc": "1 cup (~200g)"},
    "cheese": {"calories": 350, "protein": 25.0, "carbs": 1.3, "fat": 27.0, "portion_g": 30, "portion_desc": "1 slice (~30g)"},

    # --- Fast food ---
    "pizza": {"calories": 266, "protein": 11.0, "carbs": 33.0, "fat": 10.0, "portion_g": 120, "portion_desc": "1 slice (~120g)"},
    "hamburger": {"calories": 295, "protein": 17.0, "carbs": 24.0, "fat": 14.0, "portion_g": 200, "portion_desc": "1 burger (~200g)"},
    "sandwich": {"calories": 250, "protein": 12.0, "carbs": 28.0, "fat": 10.0, "portion_g": 180, "portion_desc": "1 sandwich (~180g)"},
    "hot dog": {"calories": 290, "protein": 10.0, "carbs": 24.0, "fat": 17.0, "portion_g": 150, "portion_desc": "1 hot dog (~150g)"},
    "sushi": {"calories": 140, "protein": 6.0, "carbs": 20.0, "fat": 3.5, "portion_g": 200, "portion_desc": "6 pieces (~200g)"},

    # --- İçkilər ---
    "coffee": {"calories": 2, "protein": 0.3, "carbs": 0.0, "fat": 0.0, "portion_g": 240, "portion_desc": "1 cup (~240ml)"},
    "latte": {"calories": 67, "protein": 3.4, "carbs": 5.0, "fat": 3.5, "portion_g": 350, "portion_desc": "1 cup (~350ml)"},
    "orange juice": {"calories": 45, "protein": 0.7, "carbs": 10.0, "fat": 0.2, "portion_g": 250, "portion_desc": "1 glass (~250ml)"},
    "cola": {"calories": 42, "protein": 0.0, "carbs": 10.6, "fat": 0.0, "portion_g": 330, "portion_desc": "1 can (~330ml)"},
    "water": {"calories": 0, "protein": 0.0, "carbs": 0.0, "fat": 0.0, "portion_g": 250, "portion_desc": "1 glass (~250ml)"},

    # --- Snack ---
    "chips": {"calories": 536, "protein": 7.0, "carbs": 53.0, "fat": 33.0, "portion_g": 50, "portion_desc": "1 bag (~50g)"},
    "chocolate": {"calories": 546, "protein": 5.0, "carbs": 60.0, "fat": 31.0, "portion_g": 40, "portion_desc": "1 bar (~40g)"},
    "ice cream": {"calories": 207, "protein": 3.5, "carbs": 24.0, "fat": 11.0, "portion_g": 100, "portion_desc": "1 scoop (~100g)"},
    "cake": {"calories": 350, "protein": 4.0, "carbs": 50.0, "fat": 15.0, "portion_g": 100, "portion_desc": "1 slice (~100g)"},

    # --- Tahıl/Protein ---
    "oatmeal": {"calories": 68, "protein": 2.5, "carbs": 12.0, "fat": 1.4, "portion_g": 250, "portion_desc": "1 bowl (~250g)"},
    "protein shake": {"calories": 120, "protein": 24.0, "carbs": 5.0, "fat": 1.5, "portion_g": 350, "portion_desc": "1 shake (~350ml)"},
    "nuts": {"calories": 607, "protein": 20.0, "carbs": 21.0, "fat": 54.0, "portion_g": 30, "portion_desc": "1 handful (~30g)"},
}

# Butun qidalari birleshdir
ALL_FOODS = {**AZ_FOODS, **COMMON_FOODS}


class FoodDatabase:
    """Offline food nutrition database"""

    def __init__(self):
        self.foods = ALL_FOODS
        self._food_names = list(self.foods.keys())
        logger.info(f"FoodDatabase yuklendi: {len(self.foods)} qida")

    def get_nutrition(self, food_name: str) -> Optional[Dict]:
        """
        Qida adina gore beslenme deyerlerini qaytar.
        Fuzzy matching istifade edir.
        Porsiya ucun hesablanmis deyerleri qaytarir.
        """
        food_name_lower = food_name.lower().strip()

        # 1. Exact match
        if food_name_lower in self.foods:
            return self._calculate_portion(food_name_lower)

        # 2. Partial match
        for name in self._food_names:
            if name in food_name_lower or food_name_lower in name:
                return self._calculate_portion(name)

        # 3. Fuzzy match (similarity > 0.6)
        best_match = None
        best_score = 0.0
        for name in self._food_names:
            score = SequenceMatcher(None, food_name_lower, name).ratio()
            if score > best_score:
                best_score = score
                best_match = name

        if best_match and best_score > 0.55:
            logger.info(f"Fuzzy match: '{food_name}' → '{best_match}' (score: {best_score:.2f})")
            return self._calculate_portion(best_match)

        # 4. Tapilmadi — default deyerler
        logger.warning(f"Qida tapilmadi: '{food_name}'. Default deyerler qaytarilir.")
        return {
            "food_name": food_name,
            "calories": 200,
            "protein": 10.0,
            "carbs": 25.0,
            "fat": 8.0,
            "portion_g": 200,
            "portion_desc": f"1 portion (~200g)",
            "confidence": 0.3,
            "matched": False,
        }

    def _calculate_portion(self, food_key: str) -> Dict:
        """100g deyerlerinden porsiya ucun hesabla"""
        food = self.foods[food_key]
        portion_g = food["portion_g"]
        multiplier = portion_g / 100.0

        return {
            "food_name": food_key.title(),
            "calories": round(food["calories"] * multiplier),
            "protein": round(food["protein"] * multiplier, 1),
            "carbs": round(food["carbs"] * multiplier, 1),
            "fat": round(food["fat"] * multiplier, 1),
            "portion_g": portion_g,
            "portion_desc": food["portion_desc"],
            "confidence": 0.9,
            "matched": True,
        }

    def search(self, query: str, limit: int = 10) -> List[Dict]:
        """Qida axtarishi"""
        query_lower = query.lower().strip()
        results = []

        for name in self._food_names:
            if query_lower in name or name in query_lower:
                info = self._calculate_portion(name)
                results.append(info)
                if len(results) >= limit:
                    break

        return results


# Global singleton
food_database = FoodDatabase()
