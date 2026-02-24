#!/usr/bin/env python3
"""
Pre-trained Food-101 modelini CoreML-e convert edir.

HuggingFace elcatmaz olduqda hf-mirror.com istifade edir.
Model: nateraw/food — ViT (Vision Transformer) Food-101 uzre fine-tuned

Istifade:
    python3.11 scripts/convert_food101.py
"""

import os
os.environ["HF_ENDPOINT"] = "https://hf-mirror.com"

import torch
import coremltools as ct
import json
import shutil
from transformers import AutoModelForImageClassification, AutoConfig

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
ML_DIR = os.path.join(PROJECT_DIR, "CoreVia", "Resources", "ML")


def download_and_convert():
    """Pre-trained food model yukle ve CoreML-e convert et"""

    model_name = "nateraw/food"
    print(f"📦 Model yuklenir: {model_name}")
    print(f"   Mirror: {os.environ.get('HF_ENDPOINT', 'default')}")

    # Model config
    config = AutoConfig.from_pretrained(model_name)
    print(f"✅ Config: {config.num_labels} labels")

    id2label = config.id2label
    num_classes = config.num_labels
    print(f"   Top classes: {list(id2label.values())[:5]}...")

    # Model yukle
    model = AutoModelForImageClassification.from_pretrained(model_name)
    model.eval()
    print(f"✅ Model yuklendi!")

    # Wrapper — HuggingFace dict output → tensor
    class FoodModelWrapper(torch.nn.Module):
        def __init__(self, hf_model):
            super().__init__()
            self.model = hf_model

        def forward(self, x):
            return self.model(x).logits

    wrapper = FoodModelWrapper(model)
    wrapper.eval()

    # Trace
    print("🔄 Trace edilir...")
    example_input = torch.randn(1, 3, 224, 224)
    with torch.no_grad():
        traced = torch.jit.trace(wrapper, example_input)
        test_out = traced(example_input)
    print(f"✅ Trace: output shape {test_out.shape}")
    assert test_out.shape[1] == num_classes

    # CoreML convert
    print("🔄 CoreML-e convert edilir...")

    # ViT normalization: mean=[0.5,0.5,0.5] std=[0.5,0.5,0.5]
    # pixel[0-255] → (pixel/255 - 0.5)/0.5 = pixel*(2/255) + (-1)
    mlmodel = ct.convert(
        traced,
        inputs=[
            ct.ImageType(
                name="image",
                shape=(1, 3, 224, 224),
                scale=2.0 / 255.0,
                color_layout=ct.colorlayout.RGB,
                bias=[-1.0, -1.0, -1.0],
            )
        ],
        outputs=[ct.TensorType(name="classProbs")],
        minimum_deployment_target=ct.target.iOS16,
        convert_to="mlprogram",
    )

    mlmodel.author = "CoreVia"
    mlmodel.short_description = f"Food-101 ViT classifier ({num_classes} classes, fine-tuned)"
    mlmodel.version = "2.0"

    output_path = os.path.join(ML_DIR, "FoodClassifier.mlpackage")
    if os.path.exists(output_path):
        shutil.rmtree(output_path)
    mlmodel.save(output_path)
    print(f"✅ Saved: {output_path}")

    return id2label, num_classes


def save_food_labels(id2label, num_classes):
    """food_labels.json yarat"""
    classes = []
    display_names = {}

    for i in range(num_classes):
        name = id2label.get(i, id2label.get(str(i), f"class_{i}"))
        key = name.lower().replace(" ", "_")
        classes.append(key)
        display_names[key] = name.replace("_", " ").title()

    labels = {
        "classes": classes,
        "display_names": display_names,
        "model_type": "food101_vit",
        "num_classes": num_classes,
    }

    path = os.path.join(ML_DIR, "food_labels.json")
    with open(path, "w") as f:
        json.dump(labels, f, indent=2, ensure_ascii=False)
    print(f"✅ Labels: {path} ({num_classes} classes)")
    return classes, display_names


def update_food_database(classes, display_names):
    """food_database.json yenile"""
    db_path = os.path.join(ML_DIR, "food_database.json")
    db = json.load(open(db_path)) if os.path.exists(db_path) else {}

    default = {"calories": 250, "protein": 12.0, "carbs": 30.0, "fat": 10.0,
               "portion_g": 200, "portion_desc": "1 serving (~200g)"}

    added = 0
    for name in classes:
        for variant in [name, name.replace("_", " "), display_names.get(name, "")]:
            if variant and variant not in db:
                db[variant] = dict(default)
                added += 1

    with open(db_path, "w") as f:
        json.dump(db, f, indent=2, ensure_ascii=False)
    print(f"✅ Database: {added} yeni entry")


if __name__ == "__main__":
    print("=" * 50)
    print("🍕 Food-101 → CoreML Convert")
    print("=" * 50)

    id2label, n = download_and_convert()
    classes, names = save_food_labels(id2label, n)
    update_food_database(classes, names)

    print(f"\n🎉 Hazir! {n} yemek class-i. Xcode: Cmd+Shift+K → Cmd+B")
