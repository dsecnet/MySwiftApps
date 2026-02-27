package life.corevia.app.data.local

import android.graphics.Bitmap
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.label.ImageLabeling
import com.google.mlkit.vision.label.defaults.ImageLabelerOptions
import life.corevia.app.data.model.AICalorieResult
import life.corevia.app.data.model.DetectedFood
import timber.log.Timber
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import kotlin.math.min

/**
 * On-device qida analiz pipeline-i (iOS OnDeviceFoodAnalyzer.swift ekvivalenti)
 *
 * Pipeline:
 * 1. Şəkil → ML Kit Image Labeling → etiketlər (food/non-food)
 * 2. Food etiketləri → FoodDatabaseService → kalori/makro
 * 3. Aggregate → AICalorieResult
 *
 * Tam offline işləyir — heç bir network lazım deyil
 */
@Singleton
class OnDeviceFoodAnalyzer @Inject constructor(
    private val foodDatabaseService: FoodDatabaseService
) {
    // ML Kit Image Labeler — on-device model, offline
    private val labeler = ImageLabeling.getClient(
        ImageLabelerOptions.Builder()
            .setConfidenceThreshold(0.3f) // iOS-da 0.25 istifadə olunur
            .build()
    )

    // Food-related keywords — ML Kit-in tanıdığı yemək etiketləri
    private val foodKeywords = setOf(
        "food", "dish", "meal", "cuisine", "snack", "dessert", "drink", "beverage",
        "fruit", "vegetable", "meat", "bread", "cake", "pizza", "pasta", "rice",
        "soup", "salad", "sandwich", "burger", "hamburger", "hot dog", "sushi",
        "noodle", "seafood", "fish", "chicken", "beef", "pork", "steak",
        "egg", "cheese", "chocolate", "ice cream", "cookie", "pie", "donut",
        "waffle", "pancake", "cereal", "yogurt", "milk", "juice", "coffee", "tea",
        "apple", "banana", "orange", "strawberry", "grape", "watermelon", "lemon",
        "tomato", "potato", "carrot", "broccoli", "corn", "mushroom", "onion",
        "garlic", "pepper", "cucumber", "lettuce", "spinach", "bean", "pea",
        "nut", "almond", "walnut", "peanut", "ramen", "taco", "burrito",
        "falafel", "hummus", "kebab", "curry", "biryani", "dumpling",
        "spaghetti", "lasagna", "ravioli", "gnocchi", "risotto",
        "croissant", "muffin", "baguette", "pretzel", "bagel",
        "produce", "baked goods", "fast food", "ingredient", "recipe",
        "tableware", "plate", "bowl", "cup" // təbəq/kasa varsa da yemək ola bilər
    )

    // Non-food labels to explicitly exclude
    private val nonFoodKeywords = setOf(
        "person", "human", "face", "hand", "finger", "animal", "dog", "cat",
        "car", "vehicle", "building", "sky", "cloud", "tree", "flower",
        "computer", "phone", "screen", "text", "logo", "symbol",
        "clothing", "shoe", "bag", "furniture", "chair", "table"
    )

    /**
     * Şəkili analiz edir və AICalorieResult qaytarır
     * iOS OnDeviceFoodAnalyzer.analyzeFood() ilə eyni axın
     */
    suspend fun analyzeFood(bitmap: Bitmap): AICalorieResult {
        Timber.d("🔍 OnDeviceFoodAnalyzer: Analiz başlayır...")

        val inputImage = InputImage.fromBitmap(bitmap, 0)

        // Step 1: ML Kit ilə etiketlər əldə et
        val labels = suspendCoroutine { continuation ->
            labeler.process(inputImage)
                .addOnSuccessListener { labels ->
                    continuation.resume(labels)
                }
                .addOnFailureListener { e ->
                    continuation.resumeWithException(e)
                }
        }

        Timber.d("🔍 ML Kit: ${labels.size} etiket tapıldı")
        for (label in labels) {
            Timber.d("  - ${label.text} (${label.confidence})")
        }

        // Step 2: Food-related etiketləri filtrə et
        val foodLabels = labels.filter { label ->
            val text = label.text.lowercase()
            // Check if it's food-related
            val isFood = foodKeywords.any { keyword ->
                text.contains(keyword) || keyword.contains(text)
            }
            // Check it's not explicitly non-food
            val isNotFood = nonFoodKeywords.any { keyword ->
                text == keyword
            }
            isFood && !isNotFood
        }

        Timber.d("🔍 Food etiketlər: ${foodLabels.size}")

        // Step 3: Hər food label üçün DB lookup
        val detectedFoods = mutableListOf<DetectedFood>()
        var totalCalories = 0.0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0
        var totalConfidence = 0.0

        // Əgər food labels tapılmadısa, bütün non-excluded labelları yoxla
        val labelsToProcess = if (foodLabels.isNotEmpty()) {
            foodLabels
        } else {
            // Fallback: non-food olmayan bütün labelları yoxla
            labels.filter { label ->
                val text = label.text.lowercase()
                !nonFoodKeywords.any { it == text }
            }.take(3) // Top 3
        }

        val processedNames = mutableSetOf<String>() // Dublikat yoxla

        for (label in labelsToProcess) {
            val labelText = label.text.lowercase().trim()

            // Dublikat yoxla
            if (processedNames.contains(labelText)) continue
            processedNames.add(labelText)

            // FoodDatabaseService ilə nutrition lookup
            val nutrition = foodDatabaseService.getNutrition(labelText)

            Timber.d("🔍 Nutrition: ${nutrition.foodName} - ${nutrition.calories} kcal (matched=${nutrition.matched})")

            // iOS-dakı kimi confidence hesabla:
            // ML Kit confidence (50%) + DB match (50%)
            val combinedConfidence = if (nutrition.matched) {
                min(label.confidence.toDouble() * 0.5 + nutrition.confidence * 0.5, 0.95)
            } else {
                max(label.confidence.toDouble() * 0.6, 0.3)
            }

            val food = DetectedFood(
                id = UUID.randomUUID().toString(),
                name = nutrition.foodName,
                calories = nutrition.calories.toDouble(),
                protein = nutrition.protein,
                carbs = nutrition.carbs,
                fat = nutrition.fat,
                portionGrams = nutrition.portionGrams,
                confidence = combinedConfidence
            )

            detectedFoods.add(food)
            totalCalories += nutrition.calories
            totalProtein += nutrition.protein
            totalCarbs += nutrition.carbs
            totalFat += nutrition.fat
            totalConfidence += combinedConfidence
        }

        // Heç bir food tapılmadısa → xəta at (backend fallback işə düşəcək)
        if (detectedFoods.isEmpty()) {
            Timber.w("⚠️ OnDeviceFoodAnalyzer: Heç bir yemək tapılmadı")
            throw Exception("Şəkildə yemək aşkar edilmədi")
        }

        // Average confidence, max 0.95 (iOS ilə eyni)
        val avgConfidence = min(totalConfidence / detectedFoods.size, 0.95)

        Timber.d("✅ OnDeviceFoodAnalyzer: ${detectedFoods.size} yemək tapıldı, ${totalCalories.toInt()} kcal")

        return AICalorieResult(
            foods = detectedFoods,
            totalCalories = totalCalories,
            totalProtein = totalProtein,
            totalCarbs = totalCarbs,
            totalFat = totalFat,
            confidence = avgConfidence,
            imageUrl = null // On-device — server image URL yoxdur
        )
    }

    private fun max(a: Double, b: Double): Double = if (a > b) a else b
}
