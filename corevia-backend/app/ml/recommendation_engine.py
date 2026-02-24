"""
XGBoost Recommendation Engine

User profil + heftelik data + gundelik survey → ferdileshdirilmish tovsiyeler.

Xarici AI API istifade etmir — local ML.
Ilkin versiya rule-based + scoring, data toplanan kimi XGBoost-a kecirilecek.
"""

import logging
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)


# Tovsiye shablonlari (AZ/EN/RU)
RECOMMENDATION_TEMPLATES = {
    "workout": {
        "no_workout": {
            "az": {"title": "Məşqə başla!", "description": "Bu həftə heç bir məşq etməmisən. Sadəcə 20 dəqiqəlik gəzintidən başla."},
            "en": {"title": "Start exercising!", "description": "You haven't worked out this week. Start with just a 20-min walk."},
            "ru": {"title": "Начни тренировку!", "description": "На этой неделе тренировок не было. Начните с 20-минутной прогулки."},
        },
        "low_workout": {
            "az": {"title": "Məşq tezliyini artır", "description": "Həftədə 1-2 məşq kifayət deyil. Ən azı 3-4 dəfə məşq et."},
            "en": {"title": "Increase workout frequency", "description": "1-2 workouts per week isn't enough. Aim for at least 3-4 times."},
            "ru": {"title": "Увеличьте частоту", "description": "1-2 тренировки в неделю недостаточно. Стремитесь к 3-4 разам."},
        },
        "good_workout": {
            "az": {"title": "Əla gedirsən! 💪", "description": "Məşq rejimin yaxşıdır. İntensivliyi yavaş-yavaş artırmağı düşün."},
            "en": {"title": "Great progress! 💪", "description": "Your workout routine is good. Consider gradually increasing intensity."},
            "ru": {"title": "Отлично! 💪", "description": "Режим тренировок хороший. Попробуйте увеличивать интенсивность."},
        },
        "overtraining": {
            "az": {"title": "İstirahət et! ⚠️", "description": "Çox məşq edirsən. Bədənin bərpa üçün istirahətə ehtiyacı var."},
            "en": {"title": "Take a rest! ⚠️", "description": "You're overtraining. Your body needs rest for recovery."},
            "ru": {"title": "Отдохни! ⚠️", "description": "Слишком много тренировок. Телу нужен отдых."},
        },
    },
    "meal": {
        "low_calories": {
            "az": {"title": "Kalori az alırsan", "description": "Gündəlik kalori normasından aşağısan. Sağlam qidalar əlavə et."},
            "en": {"title": "Calorie intake too low", "description": "You're below your daily calorie goal. Add nutritious foods."},
            "ru": {"title": "Мало калорий", "description": "Вы ниже суточной нормы калорий. Добавьте питательные продукты."},
        },
        "high_calories": {
            "az": {"title": "Kalori çoxdur", "description": "Gündəlik kalori hədəfini keçmisən. Porsiyaları azalt."},
            "en": {"title": "Too many calories", "description": "You've exceeded your daily calorie goal. Reduce portion sizes."},
            "ru": {"title": "Много калорий", "description": "Вы превысили суточную норму. Уменьшите порции."},
        },
        "low_protein": {
            "az": {"title": "Protein az alırsan", "description": "Əzələ inkişafı üçün daha çox protein lazımdır. Toyuq, balıq, yumurta ye."},
            "en": {"title": "Low protein intake", "description": "You need more protein for muscle growth. Add chicken, fish, eggs."},
            "ru": {"title": "Мало белка", "description": "Для роста мышц нужно больше белка. Добавьте курицу, рыбу, яйца."},
        },
        "balanced": {
            "az": {"title": "Qidalanma balansda 👍", "description": "Kalori və makro dəyərlərin normaldadır. Davam et!"},
            "en": {"title": "Diet is balanced 👍", "description": "Your calories and macros are on track. Keep it up!"},
            "ru": {"title": "Питание сбалансировано 👍", "description": "Калории и макросы в норме. Так держать!"},
        },
    },
    "hydration": {
        "low_water": {
            "az": {"title": "Daha çox su iç! 💧", "description": "Gündə ən azı 8 stəkan su iç. Su metabolizmanı sürətləndirir."},
            "en": {"title": "Drink more water! 💧", "description": "Drink at least 8 glasses per day. Water boosts metabolism."},
            "ru": {"title": "Пей больше воды! 💧", "description": "Пейте минимум 8 стаканов в день."},
        },
        "good_water": {
            "az": {"title": "Su norma ✓", "description": "Su qəbulun yaxşıdır. Davam et!"},
            "en": {"title": "Water intake good ✓", "description": "Your water intake is on track. Keep it up!"},
            "ru": {"title": "Вода в норме ✓", "description": "Потребление воды в норме. Продолжайте!"},
        },
    },
    "sleep": {
        "low_sleep": {
            "az": {"title": "Daha çox yat! 😴", "description": "Yuxu bərpa üçün çox vacibdir. Ən azı 7-8 saat yat."},
            "en": {"title": "Sleep more! 😴", "description": "Sleep is crucial for recovery. Aim for 7-8 hours."},
            "ru": {"title": "Спи больше! 😴", "description": "Сон важен для восстановления. Спите 7-8 часов."},
        },
        "poor_quality": {
            "az": {"title": "Yuxu keyfiyyəti aşağıdır", "description": "Yatmadan əvvəl ekranlardan uzaq dur. Rahat mühit yarat."},
            "en": {"title": "Poor sleep quality", "description": "Avoid screens before bed. Create a comfortable environment."},
            "ru": {"title": "Плохое качество сна", "description": "Избегайте экранов перед сном."},
        },
    },
    "rest": {
        "high_stress": {
            "az": {"title": "Stress yüksəkdir ⚠️", "description": "Meditasiya və ya nəfəs məşqləri et. Gündə 10 dəqiqə kifayətdir."},
            "en": {"title": "High stress ⚠️", "description": "Try meditation or breathing exercises. 10 minutes daily."},
            "ru": {"title": "Высокий стресс ⚠️", "description": "Попробуйте медитацию или дыхательные упражнения."},
        },
        "muscle_soreness": {
            "az": {"title": "Əzələ ağrısı var", "description": "Stretching və yüngül yürüyüş bərpa üçün kömək edəcək."},
            "en": {"title": "Muscle soreness", "description": "Stretching and light walking will help recovery."},
            "ru": {"title": "Мышечная боль", "description": "Растяжка и легкая ходьба помогут восстановлению."},
        },
    },
}


class RecommendationEngine:
    """Rule-based + scoring recommendation engine"""

    def __init__(self):
        self._xgb_model = None
        self._try_load_xgb()
        logger.info("RecommendationEngine initialized")

    def _try_load_xgb(self):
        """XGBoost model varsa yukle (optional)"""
        try:
            from pathlib import Path
            model_path = Path(__file__).parent / "weights" / "recommendation_xgb.json"
            if model_path.exists():
                import xgboost as xgb
                self._xgb_model = xgb.Booster()
                self._xgb_model.load_model(str(model_path))
                logger.info("XGBoost recommendation model yuklendi")
        except Exception as e:
            logger.info(f"XGBoost model yoxdur, rule-based mode: {e}")

    def generate_recommendations(
        self, user_data: Dict, survey_data: Optional[Dict] = None, language: str = "az"
    ) -> Dict:
        """User datalarindan tovsiyeler generasiya et"""
        lang = language if language in ("az", "en", "ru") else "az"

        recommendations = []
        warnings = []
        nutrition_tips = []
        workout_tips = []
        weekly_score = 50

        # Workout analysis
        wk = user_data.get("heftelik_mesq", {})
        workout_count = wk.get("mesq_sayi", 0)
        total_min = wk.get("umumi_deqiqe", 0)

        if workout_count == 0:
            rec = RECOMMENDATION_TEMPLATES["workout"]["no_workout"][lang]
            recommendations.append({"type": "workout", "priority": 1, **rec})
            workout_tips.append(rec["description"])
            weekly_score -= 15
        elif workout_count <= 2:
            rec = RECOMMENDATION_TEMPLATES["workout"]["low_workout"][lang]
            recommendations.append({"type": "workout", "priority": 2, **rec})
            workout_tips.append(rec["description"])
            weekly_score -= 5
        elif workout_count <= 5:
            rec = RECOMMENDATION_TEMPLATES["workout"]["good_workout"][lang]
            recommendations.append({"type": "workout", "priority": 3, **rec})
            workout_tips.append(rec["description"])
            weekly_score += 10
        else:
            rec = RECOMMENDATION_TEMPLATES["workout"]["overtraining"][lang]
            recommendations.append({"type": "workout", "priority": 1, **rec})
            warnings.append(rec["description"])
            weekly_score -= 10

        # Nutrition analysis
        fd = user_data.get("heftelik_qidalanma", {})
        daily_avg_cal = fd.get("gunluk_ortalama_kalori", 0)
        total_protein = fd.get("umumi_protein", 0)

        weight = user_data.get("ceki") or 70
        height = user_data.get("boy") or 170
        age = user_data.get("yas") or 25
        goal = user_data.get("meqsed", "stay_fit")

        bmr = 10 * weight + 6.25 * height - 5 * age + 5
        target_cal = bmr * 1.55
        if goal == "weight_loss":
            target_cal *= 0.85
        elif goal == "muscle_gain":
            target_cal *= 1.15

        if daily_avg_cal > 0:
            if daily_avg_cal < target_cal * 0.7:
                rec = RECOMMENDATION_TEMPLATES["meal"]["low_calories"][lang]
                recommendations.append({"type": "meal", "priority": 2, **rec})
                nutrition_tips.append(rec["description"])
                weekly_score -= 5
            elif daily_avg_cal > target_cal * 1.3:
                rec = RECOMMENDATION_TEMPLATES["meal"]["high_calories"][lang]
                recommendations.append({"type": "meal", "priority": 2, **rec})
                nutrition_tips.append(rec["description"])
                weekly_score -= 5
            else:
                rec = RECOMMENDATION_TEMPLATES["meal"]["balanced"][lang]
                recommendations.append({"type": "meal", "priority": 3, **rec})
                nutrition_tips.append(rec["description"])
                weekly_score += 10

        daily_protein = total_protein / 7 if total_protein > 0 else 0
        if 0 < daily_protein < weight * 0.8:
            rec = RECOMMENDATION_TEMPLATES["meal"]["low_protein"][lang]
            recommendations.append({"type": "meal", "priority": 2, **rec})
            nutrition_tips.append(rec["description"])

        # Survey-based analysis
        if survey_data:
            water = survey_data.get("water_glasses", 0)
            if water < 6:
                rec = RECOMMENDATION_TEMPLATES["hydration"]["low_water"][lang]
                recommendations.append({"type": "hydration", "priority": 2, **rec})
                weekly_score -= 5
            else:
                rec = RECOMMENDATION_TEMPLATES["hydration"]["good_water"][lang]
                recommendations.append({"type": "hydration", "priority": 3, **rec})
                weekly_score += 5

            sleep_hours = survey_data.get("sleep_hours", 7)
            sleep_quality = survey_data.get("sleep_quality", 3)
            if sleep_hours < 6:
                rec = RECOMMENDATION_TEMPLATES["sleep"]["low_sleep"][lang]
                recommendations.append({"type": "sleep", "priority": 1, **rec})
                warnings.append(rec["description"])
                weekly_score -= 10
            elif sleep_quality <= 2:
                rec = RECOMMENDATION_TEMPLATES["sleep"]["poor_quality"][lang]
                recommendations.append({"type": "sleep", "priority": 2, **rec})
                weekly_score -= 5

            stress = survey_data.get("stress_level", 3)
            if stress >= 4:
                rec = RECOMMENDATION_TEMPLATES["rest"]["high_stress"][lang]
                recommendations.append({"type": "rest", "priority": 1, **rec})
                warnings.append(rec["description"])
                weekly_score -= 10

            soreness = survey_data.get("muscle_soreness", 3)
            if soreness >= 4:
                rec = RECOMMENDATION_TEMPLATES["rest"]["muscle_soreness"][lang]
                recommendations.append({"type": "rest", "priority": 2, **rec})
                weekly_score -= 5

            energy = survey_data.get("energy_level", 3)
            mood = survey_data.get("mood", 3)
            if energy >= 4 and mood >= 4:
                weekly_score += 5

        weekly_score = max(0, min(100, weekly_score))

        # Summary
        summary = self._generate_summary(weekly_score, workout_count, daily_avg_cal, lang)

        return {
            "summary": summary,
            "nutrition_tips": nutrition_tips[:3] or [RECOMMENDATION_TEMPLATES["meal"]["balanced"][lang]["description"]],
            "workout_tips": workout_tips[:3] or [RECOMMENDATION_TEMPLATES["workout"]["good_workout"][lang]["description"]],
            "warnings": warnings[:3],
            "weekly_score": weekly_score,
            "recommendations": recommendations,
        }

    def _generate_summary(self, score: int, workouts: int, daily_cal: int, lang: str) -> str:
        s = {
            "az": {80: f"Əla gedirsən! Bu həftə {workouts} məşq etmisən.", 60: f"Yaxşı irəliləyirsən. {workouts} məşq etmisən.", 40: f"Orta səviyyədəsən. Həftədə {workouts} məşq.", 0: "İnkişaf lazımdır. Rejimi yenidən nəzərdən keçir."},
            "en": {80: f"Excellent! {workouts} workouts this week.", 60: f"Good progress. {workouts} workouts done.", 40: f"Average. {workouts} workouts this week.", 0: "Improvement needed."},
            "ru": {80: f"Отлично! {workouts} тренировок.", 60: f"Хороший прогресс. {workouts} тренировок.", 40: f"Средний уровень. {workouts} тренировок.", 0: "Нужны улучшения."},
        }
        ls = s.get(lang, s["az"])
        if score >= 80: return ls[80]
        elif score >= 60: return ls[60]
        elif score >= 40: return ls[40]
        else: return ls[0]
