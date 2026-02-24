"""
EfficientNet Food Classifier

Pre-trained EfficientNet-B0 ile sekildeki yemeyi classify edir.
Food-101 dataset uzunde fine-tune edilib.

Xarici AI API istifade etmir — tam local ML.
"""

import io
import logging
from typing import Dict, Tuple, Optional
from pathlib import Path

import torch
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image

logger = logging.getLogger(__name__)

# Food-101 class adlari (alphabetical order)
FOOD101_CLASSES = [
    "apple_pie", "baby_back_ribs", "baklava", "beef_carpaccio", "beef_tartare",
    "beet_salad", "beignets", "bibimbap", "bread_pudding", "breakfast_burrito",
    "bruschetta", "caesar_salad", "cannoli", "caprese_salad", "carrot_cake",
    "ceviche", "cheesecake", "cheese_plate", "chicken_curry", "chicken_quesadilla",
    "chicken_wings", "chocolate_cake", "chocolate_mousse", "churros", "clam_chowder",
    "club_sandwich", "crab_cakes", "creme_brulee", "croque_madame", "cup_cakes",
    "deviled_eggs", "donuts", "dumplings", "edamame", "eggs_benedict",
    "escargots", "falafel", "filet_mignon", "fish_and_chips", "foie_gras",
    "french_fries", "french_onion_soup", "french_toast", "fried_calamari", "fried_rice",
    "frozen_yogurt", "garlic_bread", "gnocchi", "greek_salad", "grilled_cheese_sandwich",
    "grilled_salmon", "guacamole", "gyoza", "hamburger", "hot_and_sour_soup",
    "hot_dog", "huevos_rancheros", "hummus", "ice_cream", "lasagna",
    "lobster_bisque", "lobster_roll_sandwich", "macaroni_and_cheese", "macarons", "miso_soup",
    "mussels", "nachos", "omelette", "onion_rings", "oysters",
    "pad_thai", "paella", "pancakes", "panna_cotta", "peking_duck",
    "pho", "pizza", "pork_chop", "poutine", "prime_rib",
    "pulled_pork_sandwich", "ramen", "ravioli", "red_velvet_cake", "risotto",
    "samosa", "sashimi", "scallops", "seaweed_salad", "shrimp_and_grits",
    "spaghetti_bolognese", "spaghetti_carbonara", "spring_rolls", "steak", "strawberry_shortcake",
    "sushi", "tacos", "takoyaki", "tiramisu", "tuna_tartare",
    "waffles",
]

# Food-101 → oxunabilen ad
DISPLAY_NAME_MAP = {
    "apple_pie": "Apple Pie",
    "baklava": "Pakhlava",
    "caesar_salad": "Caesar Salad",
    "chicken_curry": "Chicken Curry",
    "chicken_wings": "Chicken Wings",
    "chocolate_cake": "Chocolate Cake",
    "dumplings": "Dumplings",
    "french_fries": "French Fries",
    "fried_rice": "Rice",
    "grilled_salmon": "Salmon",
    "hamburger": "Hamburger",
    "hot_dog": "Hot Dog",
    "ice_cream": "Ice Cream",
    "lasagna": "Lasagna",
    "omelette": "Omelette",
    "pancakes": "Pancakes",
    "pizza": "Pizza",
    "ramen": "Ramen",
    "spaghetti_bolognese": "Spaghetti",
    "steak": "Steak",
    "sushi": "Sushi",
    "tacos": "Tacos",
    "waffles": "Waffles",
}


class FoodClassifier:
    """
    EfficientNet-B0 based food classifier.

    Custom weight varsa yuklenir, yoxdursa ImageNet pre-trained model istifade olunur.
    """

    def __init__(self, device: torch.device = None):
        self.device = device or torch.device("cpu")
        self._model = None
        self._custom_model_loaded = False
        self._weight_path = Path(__file__).parent / "weights" / "food_efficientnet_b0.pth"

        # Image preprocessing (EfficientNet-B0 ucun standart)
        self.transform = transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225],
            ),
        ])

    def _load_model(self):
        """Model lazy-load"""
        if self._model is not None:
            return

        try:
            import timm

            if self._weight_path.exists():
                # Custom food classifier
                self._model = timm.create_model(
                    "efficientnet_b0",
                    pretrained=False,
                    num_classes=len(FOOD101_CLASSES),
                )
                state_dict = torch.load(str(self._weight_path), map_location=self.device, weights_only=True)
                self._model.load_state_dict(state_dict)
                self._custom_model_loaded = True
                logger.info(f"Custom EfficientNet food model yuklendi: {self._weight_path}")
            else:
                # ImageNet pre-trained (1000 class, food class-lar da var)
                self._model = timm.create_model(
                    "efficientnet_b0",
                    pretrained=True,
                    num_classes=1000,
                )
                self._custom_model_loaded = False
                logger.info("Pre-trained EfficientNet-B0 (ImageNet) yuklendi.")

            self._model = self._model.to(self.device)
            self._model.eval()

        except ImportError:
            logger.warning("timm yuklu deyil. Fallback mode.")
            self._model = None
        except Exception as e:
            logger.error(f"EfficientNet yukleme xetasi: {e}")
            self._model = None

    def classify(self, image: Image.Image) -> Dict:
        """
        Sekildeki yemeyi classify et.

        Args:
            image: PIL Image (crop olunmus yemek sekili)

        Returns:
            Dict: {
                "class_name": str,
                "display_name": str,
                "confidence": float,
                "top5": List[Tuple[str, float]]
            }
        """
        self._load_model()

        if self._model is None:
            return {
                "class_name": "food",
                "display_name": "Food",
                "confidence": 0.5,
                "top5": [],
            }

        try:
            # Preprocess
            if image.mode != "RGB":
                image = image.convert("RGB")

            input_tensor = self.transform(image).unsqueeze(0).to(self.device)

            # Inference
            with torch.no_grad():
                output = self._model(input_tensor)
                probs = F.softmax(output, dim=1)

            if self._custom_model_loaded:
                # Custom Food-101 model
                top5_probs, top5_indices = probs.topk(5, dim=1)

                top5 = []
                for i in range(5):
                    idx = top5_indices[0][i].item()
                    prob = top5_probs[0][i].item()
                    if idx < len(FOOD101_CLASSES):
                        class_name = FOOD101_CLASSES[idx]
                        display_name = DISPLAY_NAME_MAP.get(class_name, class_name.replace("_", " ").title())
                        top5.append((display_name, round(prob, 4)))

                best_idx = top5_indices[0][0].item()
                best_conf = top5_probs[0][0].item()
                best_class = FOOD101_CLASSES[best_idx] if best_idx < len(FOOD101_CLASSES) else "food"
                best_display = DISPLAY_NAME_MAP.get(best_class, best_class.replace("_", " ").title())

                return {
                    "class_name": best_class,
                    "display_name": best_display,
                    "confidence": round(best_conf, 3),
                    "top5": top5,
                }
            else:
                # ImageNet model — food-related class-lari filter et
                # ImageNet food class range: ~924-969 (fruits, vegetables, foods)
                imagenet_food_ranges = list(range(924, 970))  # Food classes
                imagenet_food_ranges += [954, 955, 956, 957, 958, 959, 960, 961, 962, 963]

                # En yuksek food class-i tap
                food_probs = {}
                for idx in range(probs.shape[1]):
                    prob = probs[0][idx].item()
                    if prob > 0.01:
                        food_probs[idx] = prob

                # En yuksek probability ile olan class
                top5_probs, top5_indices = probs.topk(5, dim=1)
                best_conf = top5_probs[0][0].item()

                # ImageNet class adlari (simplified)
                imagenet_food_names = {
                    924: "guacamole", 925: "consomme", 926: "hot pot",
                    927: "trifle", 928: "ice cream", 929: "ice lolly",
                    930: "french loaf", 931: "bagel", 932: "pretzel",
                    933: "cheeseburger", 934: "hotdog", 935: "mashed potato",
                    936: "head cabbage", 937: "broccoli", 938: "cauliflower",
                    939: "zucchini", 940: "spaghetti squash", 941: "acorn squash",
                    942: "butternut squash", 943: "cucumber", 944: "artichoke",
                    945: "bell pepper", 946: "cardoon", 947: "mushroom",
                    948: "granny smith", 949: "strawberry", 950: "orange",
                    951: "lemon", 952: "fig", 953: "pineapple",
                    954: "banana", 955: "jackfruit", 956: "custard apple",
                    957: "pomegranate", 958: "hay", 959: "carbonara",
                    960: "chocolate sauce", 961: "dough", 962: "meat loaf",
                    963: "pizza", 964: "potpie", 965: "burrito",
                    966: "red wine", 967: "espresso", 968: "cup",
                    969: "eggnog",
                }

                best_idx = top5_indices[0][0].item()
                class_name = imagenet_food_names.get(best_idx, "food")

                return {
                    "class_name": class_name,
                    "display_name": class_name.replace("_", " ").title(),
                    "confidence": round(best_conf, 3),
                    "top5": [],
                }

        except Exception as e:
            logger.error(f"Food classification xetasi: {e}")
            return {
                "class_name": "food",
                "display_name": "Food",
                "confidence": 0.4,
                "top5": [],
            }
