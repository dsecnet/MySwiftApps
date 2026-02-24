"""
CoreVia — Qida verilənlər bazasını JSON-a export et

56 Azerbaycan + 60+ beynəlxalq qida — iOS app bundle-ına əlavə olunacaq.

Istifadə:
    cd corevia-backend
    python scripts/export_food_database.py

Output:
    scripts/output/food_database.json
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

OUTPUT_DIR = Path(__file__).parent / "output"
OUTPUT_DIR.mkdir(exist_ok=True)


def export_database():
    from app.ml.food_database import ALL_FOODS

    data = {}
    for name, info in ALL_FOODS.items():
        data[name] = {
            "calories": info["calories"],
            "protein": info["protein"],
            "carbs": info["carbs"],
            "fat": info["fat"],
            "portion_g": info["portion_g"],
            "portion_desc": info["portion_desc"],
        }

    output_path = OUTPUT_DIR / "food_database.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Food database exported: {output_path}")
    print(f"   Total foods: {len(data)}")

    # Kateqoriya sayları
    from app.ml.food_database import AZ_FOODS, COMMON_FOODS
    print(f"   Azerbaycan foods: {len(AZ_FOODS)}")
    print(f"   International foods: {len(COMMON_FOODS)}")


if __name__ == "__main__":
    export_database()
