package life.corevia.app.data.local

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * On-device qida verilənlər bazası servisi
 * USDA + Azərbaycan yeməkləri — offline nutrition lookup
 * iOS FoodDatabaseService.swift ilə eyni matching logic
 */

data class FoodNutritionInfo(
    val foodName: String,
    val caloriesPer100g: Double,
    val proteinPer100g: Double,
    val carbsPer100g: Double,
    val fatPer100g: Double,
    val portionGrams: Double,
    val portionDesc: String
)

data class PortionNutrition(
    val foodName: String,
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val portionGrams: Double,
    val portionDesc: String,
    val confidence: Double,
    val matched: Boolean
)

@Singleton
class FoodDatabaseService @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val foods = mutableMapOf<String, FoodNutritionInfo>()
    private val foodNames = mutableListOf<String>()
    private var isLoaded = false

    init {
        loadDatabase()
    }

    // MARK: - Load

    private fun loadDatabase() {
        try {
            val jsonString = context.assets.open("food_database.json")
                .bufferedReader()
                .use { it.readText() }

            val json = Json { ignoreUnknownKeys = true }
            val jsonObject = json.decodeFromString<JsonObject>(jsonString)

            for ((name, value) in jsonObject) {
                val info = value.jsonObject
                val lowerName = name.lowercase()
                val displayName = name.replace("_", " ")
                    .split(" ")
                    .joinToString(" ") { it.replaceFirstChar { c -> c.uppercase() } }

                val entry = FoodNutritionInfo(
                    foodName = displayName,
                    caloriesPer100g = info["calories"]?.jsonPrimitive?.double ?: 0.0,
                    proteinPer100g = info["protein"]?.jsonPrimitive?.double ?: 0.0,
                    carbsPer100g = info["carbs"]?.jsonPrimitive?.double ?: 0.0,
                    fatPer100g = info["fat"]?.jsonPrimitive?.double ?: 0.0,
                    portionGrams = info["portion_g"]?.jsonPrimitive?.double ?: 200.0,
                    portionDesc = info["portion_desc"]?.jsonPrimitive?.content ?: "1 portion"
                )

                // Original key
                foods[name] = entry
                // Lowercase key
                if (lowerName != name) foods[lowerName] = entry
                // Underscore variant
                val underscoreKey = lowerName.replace(" ", "_")
                if (underscoreKey != lowerName) foods[underscoreKey] = entry
                // Space variant
                val spaceKey = lowerName.replace("_", " ")
                if (spaceKey != lowerName) foods[spaceKey] = entry
            }

            foodNames.addAll(foods.keys)
            isLoaded = true
            Timber.d("✅ FoodDatabase: ${foods.size} qida yükləndi")
        } catch (e: Exception) {
            Timber.e("⚠️ food_database.json yüklənmədi: ${e.message}")
        }
    }

    // MARK: - Lookup

    /**
     * Qida adına görə besləmə dəyərlərini qaytarır (porsiya üçün hesablanmış)
     * iOS FoodDatabaseService.getNutrition() ilə eyni logic
     */
    fun getNutrition(foodName: String): PortionNutrition {
        val query = foodName.lowercase().trim()
        val queryUnderscore = query.replace(" ", "_")
        val querySpace = query.replace("_", " ")

        // 1. Exact match (3 variant: original, underscore, space)
        for (variant in listOf(query, queryUnderscore, querySpace)) {
            foods[variant]?.let { return calculatePortion(it) }
        }

        // 2. Partial match
        for (name in foodNames) {
            val nameLower = name.lowercase()
            if (nameLower.contains(query) || query.contains(nameLower)
                || nameLower.contains(querySpace) || querySpace.contains(nameLower)
                || nameLower.contains(queryUnderscore) || queryUnderscore.contains(nameLower)
            ) {
                foods[name]?.let { return calculatePortion(it) }
            }
        }

        // 3. Fuzzy match (LCS similarity > 0.55)
        var bestMatch: String? = null
        var bestScore = 0.0

        for (name in foodNames) {
            val score = stringSimilarity(query, name)
            if (score > bestScore) {
                bestScore = score
                bestMatch = name
            }
        }

        if (bestMatch != null && bestScore > 0.55) {
            foods[bestMatch]?.let { return calculatePortion(it) }
        }

        // 4. Default fallback
        return PortionNutrition(
            foodName = foodName.replaceFirstChar { it.uppercase() },
            calories = 200,
            protein = 10.0,
            carbs = 25.0,
            fat = 8.0,
            portionGrams = 200.0,
            portionDesc = "1 portion (~200g)",
            confidence = 0.3,
            matched = false
        )
    }

    // MARK: - Helpers

    private fun calculatePortion(food: FoodNutritionInfo): PortionNutrition {
        val multiplier = food.portionGrams / 100.0
        return PortionNutrition(
            foodName = food.foodName,
            calories = (food.caloriesPer100g * multiplier).roundToInt(),
            protein = (food.proteinPer100g * multiplier * 10).roundToInt() / 10.0,
            carbs = (food.carbsPer100g * multiplier * 10).roundToInt() / 10.0,
            fat = (food.fatPer100g * multiplier * 10).roundToInt() / 10.0,
            portionGrams = food.portionGrams,
            portionDesc = food.portionDesc,
            confidence = 0.9,
            matched = true
        )
    }

    /**
     * SequenceMatcher ekvivalenti — Longest Common Subsequence ratio
     * iOS-dakı stringSimilarity() ilə eyni logic
     */
    private fun stringSimilarity(a: String, b: String): Double {
        val aLen = a.length
        val bLen = b.length
        if (aLen == 0 || bLen == 0) return 0.0

        // LCS dynamic programming
        val dp = Array(aLen + 1) { IntArray(bLen + 1) }
        for (i in 1..aLen) {
            for (j in 1..bLen) {
                dp[i][j] = if (a[i - 1] == b[j - 1]) {
                    dp[i - 1][j - 1] + 1
                } else {
                    max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        return (2.0 * dp[aLen][bLen]) / (aLen + bLen)
    }

    fun isReady(): Boolean = isLoaded
}
