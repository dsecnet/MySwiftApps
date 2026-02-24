//
//  CoreMLFoodClassifier.swift
//  CoreVia
//
//  Dual Model Food Classifier:
//  1. Primary: Food-101 ViT (101 restoran yemekleri — pizza, steak, sushi, ramen...)
//  2. Backup: ImageNet EfficientNet-B0 (meyve/terevez — banana, apple, broccoli...)
//
//  Food-101 confidence asagidirsa → ImageNet backup yoxlanir
//  Cemisi ~150+ real yemek class-i
//

import UIKit
import CoreML

// MARK: - Classification Result

struct FoodClassification {
    let className: String       // Raw class: "pizza"
    let displayName: String     // Display: "Pizza"
    let confidence: Float
}

// MARK: - Dual Classifier

class CoreMLFoodClassifier {
    static let shared = CoreMLFoodClassifier()

    // Primary: Food-101 ViT model
    private var primaryModel: FoodClassifier?
    private var classLabels: [String] = []
    private var displayNames: [String: String] = [:]

    // Backup: ImageNet EfficientNet-B0 (meyve/terevez)
    private var backupModel: MLModel?

    // ImageNet food-related class indices (meyve, terevez, icki)
    private let imagenetFoodNames: [Int: String] = [
        // Fruits
        948: "apple", 949: "strawberry", 950: "orange", 951: "lemon",
        952: "fig", 953: "pineapple", 954: "banana", 955: "jackfruit",
        956: "custard_apple", 957: "pomegranate",
        // Vegetables
        936: "cabbage", 937: "broccoli", 938: "cauliflower", 939: "zucchini",
        940: "spaghetti_squash", 941: "acorn_squash", 942: "butternut_squash",
        943: "cucumber", 944: "artichoke", 945: "bell_pepper",
        946: "cardoon", 947: "mushroom",
        // Foods/Meals
        924: "guacamole", 925: "consomme", 926: "hot_pot",
        927: "trifle", 928: "ice_cream", 929: "ice_cream",
        930: "garlic_bread", 931: "bagel", 932: "pretzel",
        933: "hamburger", 934: "hot_dog", 935: "mashed_potato",
        959: "spaghetti_carbonara", 960: "chocolate_mousse", 961: "dough",
        962: "meat_loaf", 963: "pizza", 964: "pot_pie",
        965: "breakfast_burrito", 966: "red_wine", 967: "espresso",
        968: "coffee", 969: "eggnog",
        // Kitchen/Food adjacent
        809: "soup", 823: "steak", 567: "chocolate_cake",
        504: "espresso", 899: "waffle",
    ]

    private let imagenetDisplayNames: [Int: String] = [
        948: "Apple", 949: "Strawberry", 950: "Orange", 951: "Lemon",
        952: "Fig", 953: "Pineapple", 954: "Banana", 955: "Jackfruit",
        956: "Custard Apple", 957: "Pomegranate",
        936: "Cabbage", 937: "Broccoli", 938: "Cauliflower", 939: "Zucchini",
        940: "Squash", 941: "Squash", 942: "Butternut Squash",
        943: "Cucumber", 944: "Artichoke", 945: "Bell Pepper",
        946: "Cardoon", 947: "Mushroom",
        924: "Guacamole", 925: "Soup", 926: "Hot Pot",
        927: "Dessert", 928: "Ice Cream", 929: "Ice Cream",
        930: "Bread", 931: "Bagel", 932: "Pretzel",
        933: "Hamburger", 934: "Hot Dog", 935: "Mashed Potato",
        959: "Spaghetti Carbonara", 960: "Chocolate Mousse", 961: "Dough",
        962: "Meat Loaf", 963: "Pizza", 964: "Pot Pie",
        965: "Burrito", 966: "Red Wine", 967: "Espresso",
        968: "Coffee", 969: "Eggnog",
        809: "Soup", 823: "Steak", 567: "Chocolate Cake",
        504: "Espresso", 899: "Waffle",
    ]

    private init() {
        loadLabels()
        loadPrimaryModel()
        loadBackupModel()
    }

    // MARK: - Setup

    private func loadPrimaryModel() {
        let config = MLModelConfiguration()
        config.computeUnits = .all

        do {
            primaryModel = try FoodClassifier(configuration: config)
            print("✅ Primary: Food-101 ViT model yuklendi (\(classLabels.count) class)")
        } catch {
            print("⚠️ Primary model xetasi: \(error.localizedDescription)")
            primaryModel = nil
        }
    }

    private func loadBackupModel() {
        let config = MLModelConfiguration()
        config.computeUnits = .all

        // Backup model: FoodClassifierBackup.mlpackage (ImageNet EfficientNet-B0)
        if let url = Bundle.main.url(forResource: "FoodClassifierBackup", withExtension: "mlmodelc") {
            do {
                backupModel = try MLModel(contentsOf: url, configuration: config)
                print("✅ Backup: ImageNet model yuklendi (meyve/terevez)")
            } catch {
                print("⚠️ Backup model xetasi: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ FoodClassifierBackup model tapilmadi — yalniz Food-101 istifade olunacaq")
        }
    }

    private func loadLabels() {
        guard let url = Bundle.main.url(forResource: "food_labels", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            loadDefaultLabels()
            return
        }

        if let classes = json["classes"] as? [String] { classLabels = classes }
        if let names = json["display_names"] as? [String: String] { displayNames = names }
        if classLabels.isEmpty { loadDefaultLabels() }

        print("✅ Food labels: \(classLabels.count) class")
    }

    private func loadDefaultLabels() {
        classLabels = [
            "apple_pie", "baby_back_ribs", "baklava", "beef_carpaccio", "beef_tartare",
            "beet_salad", "beignets", "bibimbap", "bread_pudding", "breakfast_burrito",
            "bruschetta", "caesar_salad", "cannoli", "caprese_salad", "carrot_cake",
            "ceviche", "cheese_plate", "cheesecake", "chicken_curry", "chicken_quesadilla",
            "chicken_wings", "chocolate_cake", "chocolate_mousse", "churros", "clam_chowder",
            "club_sandwich", "crab_cakes", "creme_brulee", "croque_madame", "cup_cakes",
            "deviled_eggs", "donuts", "dumplings", "edamame", "eggs_benedict",
            "escargots", "falafel", "filet_mignon", "fish_and_chips", "fish_tacos",
            "foie_gras", "french_fries", "french_onion_soup", "french_toast", "fried_calamari",
            "fried_rice", "frozen_yogurt", "garlic_bread", "gnocchi", "greek_salad",
            "grilled_cheese_sandwich", "grilled_salmon", "guacamole", "gyoza", "hamburger",
            "hot_and_sour_soup", "hot_dog", "huevos_rancheros", "hummus", "ice_cream",
            "lasagna", "lobster_bisque", "lobster_roll_sandwich", "macaroni_and_cheese",
            "macarons", "miso_soup", "mussels", "nachos", "omelette",
            "onion_rings", "oysters", "pad_thai", "paella", "pancakes",
            "panna_cotta", "peking_duck", "pho", "pizza", "pork_chop",
            "poutine", "prime_rib", "pulled_pork_sandwich", "ramen", "ravioli",
            "red_velvet_cake", "risotto", "samosa", "sashimi", "scallops",
            "seaweed_salad", "shrimp_and_grits", "spaghetti_bolognese", "spaghetti_carbonara",
            "spring_rolls", "steak", "strawberry_shortcake", "sushi", "tacos",
            "takoyaki", "tiramisu", "tuna_tartare", "waffles"
        ]
    }

    // MARK: - Dual Classification

    func classify(image: CGImage) async throws -> FoodClassification {
        // 1. Primary: Food-101 ViT
        let primaryResult = classifyWithPrimary(image: image)

        // Eger Food-101 confidence yuksekdirse → basa catdi
        if let result = primaryResult, result.confidence >= 0.4 {
            print("✅ Primary (Food-101): \(result.displayName) (\(String(format: "%.2f", result.confidence)))")
            return result
        }

        // 2. Backup: ImageNet (meyve/terevez)
        let backupResult = classifyWithBackup(image: image)

        // Her iki neticeni muqayise et
        if let primary = primaryResult, let backup = backupResult {
            // Backup daha yaxsidirsa (meyve/terevez ola biler)
            if backup.confidence > primary.confidence {
                print("✅ Backup (ImageNet): \(backup.displayName) (\(String(format: "%.2f", backup.confidence))) > Primary: \(primary.displayName) (\(String(format: "%.2f", primary.confidence)))")
                return backup
            }
            print("✅ Primary (Food-101): \(primary.displayName) (\(String(format: "%.2f", primary.confidence))) >= Backup")
            return primary
        }

        if let primary = primaryResult {
            print("✅ Primary only: \(primary.displayName) (\(String(format: "%.2f", primary.confidence)))")
            return primary
        }

        if let backup = backupResult {
            print("✅ Backup only: \(backup.displayName) (\(String(format: "%.2f", backup.confidence)))")
            return backup
        }

        return FoodClassification(className: "food", displayName: "Food", confidence: 0.3)
    }

    // MARK: - Primary (Food-101 ViT)

    private func classifyWithPrimary(image: CGImage) -> FoodClassification? {
        guard let classifier = primaryModel else { return nil }

        do {
            let input = try FoodClassifierInput(imageWith: image)
            let output = try classifier.prediction(input: input)
            let logits = output.classProbs
            let allProbs = softmax(logits)
            let top5 = topK(allProbs, k: 5)

            print("🔍 Food-101 top5:")
            for (idx, prob) in top5 {
                let name = idx < classLabels.count ? classLabels[idx] : "?"
                let display = displayNames[name] ?? name.replacingOccurrences(of: "_", with: " ").capitalized
                print("   [\(idx)] \(display) = \(String(format: "%.3f", prob))")
            }

            guard let best = top5.first else { return nil }
            let className = best.0 < classLabels.count ? classLabels[best.0] : "food"
            let displayName = displayNames[className]
                ?? className.replacingOccurrences(of: "_", with: " ").capitalized

            return FoodClassification(
                className: className,
                displayName: displayName,
                confidence: max(best.1, 0.1)
            )
        } catch {
            print("⚠️ Primary prediction xetasi: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Backup (ImageNet EfficientNet-B0)

    private func classifyWithBackup(image: CGImage) -> FoodClassification? {
        guard let model = backupModel else { return nil }

        do {
            // MLModel birbaşa istifade — FoodClassifierBackup class yoxdur
            let imageConstraint = model.modelDescription.inputDescriptionsByName["image"]?.imageConstraint
            let width = imageConstraint?.pixelsWide ?? 224
            let height = imageConstraint?.pixelsHigh ?? 224

            let featureValue = try MLFeatureValue(cgImage: image, pixelsWide: width, pixelsHigh: height,
                                                   pixelFormatType: kCVPixelFormatType_32BGRA,
                                                   options: nil)
            let provider = try MLDictionaryFeatureProvider(dictionary: ["image": featureValue])
            let prediction = try model.prediction(from: provider)

            // Output: var_1150 (1x1000 tensor)
            guard let outputArray = prediction.featureValue(for: "var_1150")?.multiArrayValue else {
                return nil
            }

            let allProbs = softmax(outputArray)

            // Yalniz food class-larini yoxla
            var foodProbs: [(index: Int, prob: Float)] = []
            var foodProbSum: Float = 0

            for (index, _) in imagenetFoodNames {
                guard index < allProbs.count else { continue }
                foodProbs.append((index: index, prob: allProbs[index]))
                foodProbSum += allProbs[index]
            }

            guard foodProbSum > 0 else { return nil }

            // Food class-lar arasinda re-normalize
            var renormalized = foodProbs.map { (index: $0.index, prob: $0.prob / foodProbSum) }
            renormalized.sort { $0.prob > $1.prob }

            let top3 = Array(renormalized.prefix(3))
            print("🔍 ImageNet backup top3:")
            for item in top3 {
                let name = imagenetDisplayNames[item.index] ?? "?"
                print("   [\(item.index)] \(name) = \(String(format: "%.3f", item.prob))")
            }

            guard let best = renormalized.first else { return nil }
            let foodName = imagenetFoodNames[best.index] ?? "food"
            let displayName = imagenetDisplayNames[best.index]
                ?? foodName.replacingOccurrences(of: "_", with: " ").capitalized

            // Confidence: re-normalized × food_sum multiplier
            let multiplier = min(foodProbSum * 3.0, 1.0)
            let confidence = max(best.prob * multiplier, 0.15)

            return FoodClassification(
                className: foodName,
                displayName: displayName,
                confidence: confidence
            )
        } catch {
            print("⚠️ Backup prediction xetasi: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Softmax

    private func softmax(_ multiArray: MLMultiArray) -> [Float] {
        let count = multiArray.count
        var logits = [Float](repeating: 0, count: count)
        for i in 0..<count { logits[i] = multiArray[i].floatValue }

        let maxLogit = logits.max() ?? 0
        var expValues = [Float](repeating: 0, count: count)
        var expSum: Float = 0
        for i in 0..<count {
            let expVal = exp(logits[i] - maxLogit)
            expValues[i] = expVal
            expSum += expVal
        }

        var probs = [Float](repeating: 0, count: count)
        for i in 0..<count { probs[i] = expValues[i] / expSum }
        return probs
    }

    private func topK(_ probs: [Float], k: Int) -> [(Int, Float)] {
        let indexed = probs.enumerated().sorted { $0.element > $1.element }
        return Array(indexed.prefix(k)).map { ($0.offset, $0.element) }
    }
}
