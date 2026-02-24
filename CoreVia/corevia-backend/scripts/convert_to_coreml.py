"""
CoreVia — ML Model-lerini Core ML formatina cevir

YOLOv8n (Food Detector) ve EfficientNet-B0 (Food Classifier)
modellerin iOS Core ML formatina export edir.

Istifade:
    cd corevia-backend
    pip install coremltools
    python scripts/convert_to_coreml.py

Output:
    scripts/output/FoodDetector.mlpackage
    scripts/output/FoodClassifier.mlpackage
"""

import sys
import os
from pathlib import Path

# Project root-a add et
sys.path.insert(0, str(Path(__file__).parent.parent))

OUTPUT_DIR = Path(__file__).parent / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

WEIGHTS_DIR = Path(__file__).parent.parent / "app" / "ml" / "weights"


def convert_yolov8():
    """YOLOv8n modeli Core ML formatina cevir"""
    print("=" * 60)
    print("YOLOv8 → Core ML Conversion")
    print("=" * 60)

    try:
        from ultralytics import YOLO

        # Custom weight varsa onu istifade et, yoxdursa pretrained
        custom_path = WEIGHTS_DIR / "food_yolov8n.pt"
        if custom_path.exists():
            print(f"Custom model tapildi: {custom_path}")
            model = YOLO(str(custom_path))
        else:
            print("Custom model tapilmadi, pre-trained YOLOv8n istifade olunur.")
            model = YOLO("yolov8n.pt")

        # Core ML-e export et
        # nms=True → NMS model icine embed olunur (iOS-da ayrica yazmaq lazim olmaz)
        output_path = model.export(
            format="coreml",
            imgsz=640,
            nms=True,
        )

        # Rename / move to output dir
        import shutil
        dest = OUTPUT_DIR / "FoodDetector.mlpackage"
        if dest.exists():
            shutil.rmtree(dest)

        shutil.move(str(output_path), str(dest))
        print(f"✅ YOLOv8 Core ML model saved: {dest}")
        print(f"   Size: {sum(f.stat().st_size for f in dest.rglob('*') if f.is_file()) / 1024 / 1024:.1f} MB")

    except ImportError:
        print("❌ ultralytics paketi yuklu deyil: pip install ultralytics")
    except Exception as e:
        print(f"❌ YOLOv8 conversion xetasi: {e}")


def convert_efficientnet():
    """EfficientNet-B0 modeli Core ML formatina cevir"""
    print("\n" + "=" * 60)
    print("EfficientNet-B0 → Core ML Conversion")
    print("=" * 60)

    try:
        import torch
        import timm
        import coremltools as ct

        from app.ml.food_classifier import FOOD101_CLASSES, DISPLAY_NAME_MAP

        num_classes = len(FOOD101_CLASSES)
        custom_path = WEIGHTS_DIR / "food_efficientnet_b0.pth"

        if custom_path.exists():
            print(f"Custom model tapildi: {custom_path}")
            model = timm.create_model(
                "efficientnet_b0",
                pretrained=False,
                num_classes=num_classes,
            )
            state_dict = torch.load(str(custom_path), map_location="cpu", weights_only=True)
            model.load_state_dict(state_dict)
        else:
            print("Custom model tapilmadi, pre-trained EfficientNet-B0 istifade olunur.")
            model = timm.create_model(
                "efficientnet_b0",
                pretrained=True,
                num_classes=1000,
            )
            # ImageNet modeldir — class adlari ferqli olacaq
            num_classes = 1000

        model.eval()

        # Trace model
        example_input = torch.randn(1, 3, 224, 224)
        traced_model = torch.jit.trace(model, example_input)

        # Core ML-e cevir — preprocessing embed edilir
        # ImageType istifade edirik ki, iOS-da ayrica normalize etmeye ehtiyac olmasin
        # EfficientNet preprocessing: Normalize(mean=[0.485,0.456,0.406], std=[0.229,0.224,0.225])
        # Core ML ImageType: pixel = (pixel * scale) + bias
        # scale = 1/(255*std), bias = -mean/std
        mlmodel = ct.convert(
            traced_model,
            inputs=[
                ct.ImageType(
                    name="image",
                    shape=(1, 3, 224, 224),
                    scale=1.0 / (255.0 * 0.226),  # approximate std
                    bias=[
                        -0.485 / 0.229,  # R channel
                        -0.456 / 0.224,  # G channel
                        -0.406 / 0.225,  # B channel
                    ],
                    color_layout=ct.colorlayout.RGB,
                )
            ],
            classifier_config=ct.ClassifierConfig(
                FOOD101_CLASSES if num_classes == len(FOOD101_CLASSES) else None
            ) if num_classes == len(FOOD101_CLASSES) else None,
            minimum_deployment_target=ct.target.iOS16,
        )

        # Save
        output_path = OUTPUT_DIR / "FoodClassifier.mlpackage"
        mlmodel.save(str(output_path))
        print(f"✅ EfficientNet Core ML model saved: {output_path}")
        print(f"   Size: {sum(f.stat().st_size for f in output_path.rglob('*') if f.is_file()) / 1024 / 1024:.1f} MB")
        print(f"   Classes: {num_classes}")

    except ImportError as e:
        print(f"❌ Lazimli paket yuklu deyil: {e}")
        print("   pip install coremltools timm torch torchvision")
    except Exception as e:
        print(f"❌ EfficientNet conversion xetasi: {e}")


if __name__ == "__main__":
    print("CoreVia — ML Model Core ML Conversion")
    print(f"Output directory: {OUTPUT_DIR}\n")

    convert_yolov8()
    convert_efficientnet()

    print("\n" + "=" * 60)
    print("Conversion tamamlandi!")
    print(f"Output fayllar: {OUTPUT_DIR}")
    print("\nNovbeti addimlar:")
    print("1. FoodDetector.mlpackage → Xcode project-e əlavə et (Resources/ML/)")
    print("2. FoodClassifier.mlpackage → Xcode project-e əlavə et (Resources/ML/)")
    print("3. food_labels.json export et: python scripts/export_food_labels.py")
    print("4. food_database.json export et: python scripts/export_food_database.py")
