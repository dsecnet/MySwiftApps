"""
CoreVia — Food-101 class adlarini ve display name mapping-i JSON-a export et

iOS app bundle-ina elave olunacaq.

Istifade:
    cd corevia-backend
    python scripts/export_food_labels.py

Output:
    scripts/output/food_labels.json
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

OUTPUT_DIR = Path(__file__).parent / "output"
OUTPUT_DIR.mkdir(exist_ok=True)


def export_labels():
    from app.ml.food_classifier import FOOD101_CLASSES, DISPLAY_NAME_MAP
    from app.ml.food_detector import FOOD101_DISPLAY_NAMES

    # Hər iki source-dan display name-ləri birləşdir
    combined_display_names = {}
    combined_display_names.update(FOOD101_DISPLAY_NAMES)
    combined_display_names.update(DISPLAY_NAME_MAP)

    # Bütün Food-101 class-lar üçün display name təmin et
    all_display_names = {}
    for cls in FOOD101_CLASSES:
        if cls in combined_display_names:
            all_display_names[cls] = combined_display_names[cls]
        else:
            all_display_names[cls] = cls.replace("_", " ").title()

    data = {
        "classes": FOOD101_CLASSES,
        "display_names": all_display_names,
    }

    output_path = OUTPUT_DIR / "food_labels.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Food labels exported: {output_path}")
    print(f"   Classes: {len(FOOD101_CLASSES)}")
    print(f"   Display names: {len(all_display_names)}")


if __name__ == "__main__":
    export_labels()
