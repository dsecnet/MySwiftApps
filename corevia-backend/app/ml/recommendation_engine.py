"""
Data-Driven Recommendation Engine

User profil + heftelik data + gundelik survey + kecen hefte muqayisesi
→ ferdileshdirilmish, reqemli tovsiyeler.

Xarici AI API istifade etmir — local rule-based + scoring.
"""

import logging
from datetime import datetime
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)


class RecommendationEngine:
    """Data-driven rule-based + scoring recommendation engine"""

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

    # ──────────────────────────────────────────────
    # CLIENT RECOMMENDATIONS
    # ──────────────────────────────────────────────

    def generate_recommendations(
        self,
        user_data: Dict,
        survey_data: Optional[Dict] = None,
        prev_week_data: Optional[Dict] = None,
        language: str = "az",
    ) -> Dict:
        """User datalarindan reqemli tovsiyeler generasiya et"""
        lang = language if language in ("az", "en", "ru") else "az"

        recommendations = []
        warnings = []
        nutrition_tips = []
        workout_tips = []
        weekly_score = 50

        # User melumlatlari
        weight = user_data.get("ceki") or 70
        height = user_data.get("boy") or 170
        age = user_data.get("yas") or 25
        goal = user_data.get("meqsed", "stay_fit")
        name = user_data.get("ad", "")

        # Workout analysis
        wk = user_data.get("heftelik_mesq", {})
        workout_count = wk.get("mesq_sayi", 0)
        total_min = wk.get("umumi_deqiqe", 0)
        total_cal_burned = wk.get("yandirilan_kalori", 0)

        # BMR + hedef kalori hesablama
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
        activity_factor = 1.55
        target_cal = int(bmr * activity_factor)
        if goal == "weight_loss":
            target_cal = int(target_cal * 0.85)
        elif goal == "muscle_gain":
            target_cal = int(target_cal * 1.15)

        # ── Workout Recommendations ──
        if workout_count == 0:
            recommendations.append(self._rec(
                "workout", 1, lang,
                az=("Bu həftə heç məşq etməmisən!", f"Hədəfinə çatmaq üçün ən azı həftədə 3 dəfə məşq et. 20 dəqiqəlik gəzintidən başla — bu {int(weight * 0.5)} kcal yandırar."),
                en=("No workouts this week!", f"Aim for at least 3 workouts per week. Start with a 20-min walk — that burns about {int(weight * 0.5)} kcal."),
                ru=("Нет тренировок на этой неделе!", f"Тренируйтесь минимум 3 раза в неделю. Начните с 20-минутной прогулки — это сожжёт {int(weight * 0.5)} kcal."),
            ))
            weekly_score -= 15
        elif workout_count <= 2:
            recommendations.append(self._rec(
                "workout", 2, lang,
                az=(f"Bu həftə {workout_count} məşq etmisən", f"{total_min} dəqiqə məşq edib {total_cal_burned} kcal yandırmısan. Hədəf həftədə 3-4 dəfədir — daha {3 - workout_count} məşq əlavə et."),
                en=(f"{workout_count} workouts this week", f"You've trained {total_min} min and burned {total_cal_burned} kcal. Target is 3-4x/week — add {3 - workout_count} more."),
                ru=(f"{workout_count} тренировки на этой неделе", f"Вы тренировались {total_min} мин и сожгли {total_cal_burned} kcal. Цель 3-4 раза — добавьте ещё {3 - workout_count}."),
            ))
            weekly_score -= 5
        elif workout_count <= 5:
            recommendations.append(self._rec(
                "workout", 3, lang,
                az=(f"Əla! {workout_count} məşq, {total_min} dəqiqə 💪", f"{total_cal_burned} kcal yandırmısan. Rejimin yaxşıdır, intensivliyi yavaş-yavaş artır."),
                en=(f"Great! {workout_count} workouts, {total_min} min 💪", f"You burned {total_cal_burned} kcal. Your routine is solid — try increasing intensity gradually."),
                ru=(f"Отлично! {workout_count} тренировок, {total_min} мин 💪", f"Вы сожгли {total_cal_burned} kcal. Режим хороший — увеличивайте интенсивность."),
            ))
            weekly_score += 10
        else:
            recommendations.append(self._rec(
                "workout", 1, lang,
                az=(f"⚠️ {workout_count} məşq — çox intensivdir", f"Həftədə {workout_count} məşq overtraining riski yaradır. Bədənin bərpa üçün ən azı 2 gün istirahət lazımdır."),
                en=(f"⚠️ {workout_count} workouts — too intense", f"Training {workout_count}x/week risks overtraining. Your body needs at least 2 rest days for recovery."),
                ru=(f"⚠️ {workout_count} тренировок — слишком много", f"Тренировки {workout_count} раз/неделю создают риск перетренированности. Нужны минимум 2 дня отдыха."),
            ))
            warnings.append("Overtraining risk")
            weekly_score -= 10

        # ── Nutrition Recommendations ──
        fd = user_data.get("heftelik_qidalanma", {})
        daily_avg_cal = fd.get("gunluk_ortalama_kalori", 0)
        total_protein = fd.get("umumi_protein", 0)
        daily_protein = total_protein / 7 if total_protein > 0 else 0

        if daily_avg_cal > 0:
            cal_diff = int(target_cal - daily_avg_cal)
            if daily_avg_cal < target_cal * 0.7:
                recommendations.append(self._rec(
                    "meal", 2, lang,
                    az=(f"Gündəlik {daily_avg_cal} kcal — az alırsan", f"Hədəfin {target_cal} kcal/gün. {abs(cal_diff)} kcal əlavə et. Banan, yulaf, və qoz-fındıq əlavə etməyi düşün."),
                    en=(f"Daily {daily_avg_cal} kcal — too low", f"Your target is {target_cal} kcal/day. Add {abs(cal_diff)} kcal more. Consider bananas, oats, and nuts."),
                    ru=(f"Дневная норма {daily_avg_cal} kcal — мало", f"Ваша цель {target_cal} kcal/день. Добавьте {abs(cal_diff)} kcal. Попробуйте бананы, овсянку, орехи."),
                ))
                weekly_score -= 5
            elif daily_avg_cal > target_cal * 1.3:
                recommendations.append(self._rec(
                    "meal", 2, lang,
                    az=(f"Gündəlik {daily_avg_cal} kcal — çoxdur", f"Hədəfin {target_cal} kcal/gün. {abs(cal_diff)} kcal azalt. Porsiyaları kiçilt, şəkərli içkilərdən qaç."),
                    en=(f"Daily {daily_avg_cal} kcal — too high", f"Your target is {target_cal} kcal/day. Cut {abs(cal_diff)} kcal. Reduce portions, avoid sugary drinks."),
                    ru=(f"Дневная норма {daily_avg_cal} kcal — много", f"Ваша цель {target_cal} kcal/день. Уменьшите на {abs(cal_diff)} kcal."),
                ))
                weekly_score -= 5
            else:
                recommendations.append(self._rec(
                    "meal", 3, lang,
                    az=(f"Qidalanma balansda — {daily_avg_cal}/{target_cal} kcal 👍", f"Kalori normasını tutmusan. Makro balansına da diqqət et: protein, karbohidrat, yağ."),
                    en=(f"Diet on track — {daily_avg_cal}/{target_cal} kcal 👍", f"Calorie target met. Pay attention to macro balance: protein, carbs, fats."),
                    ru=(f"Питание в норме — {daily_avg_cal}/{target_cal} kcal 👍", f"Норма калорий соблюдена. Следите за макросами: белки, углеводы, жиры."),
                ))
                weekly_score += 10

        protein_target = weight * 1.2
        if 0 < daily_protein < weight * 0.8:
            recommendations.append(self._rec(
                "meal", 2, lang,
                az=(f"Protein: {daily_protein:.0f}g/gün — az", f"Hədəfin gündə {protein_target:.0f}g protein. {protein_target - daily_protein:.0f}g əlavə et. 100g toyuq = 31g protein."),
                en=(f"Protein: {daily_protein:.0f}g/day — low", f"Target is {protein_target:.0f}g daily. Add {protein_target - daily_protein:.0f}g more. 100g chicken = 31g protein."),
                ru=(f"Белок: {daily_protein:.0f}г/день — мало", f"Цель {protein_target:.0f}г в день. Добавьте {protein_target - daily_protein:.0f}г. 100г курицы = 31г белка."),
            ))

        # ── Goal-Specific Recommendations ──
        if goal == "weight_loss":
            deficit = daily_avg_cal - target_cal if daily_avg_cal > 0 else 0
            recommendations.append(self._rec(
                "workout", 2, lang,
                az=("Arıqlama hədəfi üçün kardio", f"Çəkin {weight}kg. Həftədə 150+ dəqiqə kardio (qaçış, velosiped) arıqlamağı sürətləndirir. Bu həftə {total_min} dəqiqə etmisən."),
                en=("Cardio for weight loss", f"Weight: {weight}kg. 150+ min cardio/week (running, cycling) accelerates fat loss. You've done {total_min} min this week."),
                ru=("Кардио для похудения", f"Вес: {weight}кг. 150+ мин кардио/неделю ускоряет похудение. На этой неделе: {total_min} мин."),
            ))
        elif goal == "muscle_gain":
            recommendations.append(self._rec(
                "meal", 2, lang,
                az=("Kütlə artımı üçün protein artır", f"Çəkin {weight}kg. Gündə ən azı {weight * 1.6:.0f}g protein lazımdır. Hazırda {daily_protein:.0f}g alırsan."),
                en=("Increase protein for muscle gain", f"Weight: {weight}kg. You need at least {weight * 1.6:.0f}g protein/day. Currently: {daily_protein:.0f}g."),
                ru=("Больше белка для набора массы", f"Вес: {weight}кг. Нужно минимум {weight * 1.6:.0f}г белка/день. Сейчас: {daily_protein:.0f}г."),
            ))

        # ── Survey-based analysis ──
        if survey_data:
            water = survey_data.get("water_glasses", 0)
            if water < 6:
                water_target = max(8, int(weight * 0.033 * 4))
                recommendations.append(self._rec(
                    "hydration", 2, lang,
                    az=(f"Su: {water} stəkan — az 💧", f"Çəkinə görə gündə ən azı {water_target} stəkan su lazımdır. {water_target - water} stəkan daha iç."),
                    en=(f"Water: {water} glasses — low 💧", f"Based on your weight, drink at least {water_target} glasses/day. Drink {water_target - water} more."),
                    ru=(f"Вода: {water} стаканов — мало 💧", f"При вашем весе нужно {water_target} стаканов/день. Выпейте ещё {water_target - water}."),
                ))
                weekly_score -= 5
            else:
                recommendations.append(self._rec(
                    "hydration", 3, lang,
                    az=(f"Su norması: {water} stəkan ✓", "Su qəbulun yaxşıdır. Məşq günlərində 2-3 stəkan əlavə et."),
                    en=(f"Water on track: {water} glasses ✓", "Good hydration. Add 2-3 extra glasses on workout days."),
                    ru=(f"Вода в норме: {water} стаканов ✓", "Гидратация хорошая. В дни тренировок пейте на 2-3 стакана больше."),
                ))
                weekly_score += 5

            sleep_hours = survey_data.get("sleep_hours", 7)
            sleep_quality = survey_data.get("sleep_quality", 3)
            if sleep_hours < 6:
                recommendations.append(self._rec(
                    "sleep", 1, lang,
                    az=(f"Yuxu: {sleep_hours} saat — az! 😴", f"Ən azı 7-8 saat yuxu lazımdır. {7 - sleep_hours:.1f} saat daha yat. Yuxusuzluq əzələ bərpasını 60% azaldır."),
                    en=(f"Sleep: {sleep_hours}h — too low! 😴", f"You need 7-8h sleep. Get {7 - sleep_hours:.1f}h more. Sleep deprivation reduces muscle recovery by 60%."),
                    ru=(f"Сон: {sleep_hours}ч — мало! 😴", f"Нужно 7-8ч сна. Спите на {7 - sleep_hours:.1f}ч больше. Недосып снижает восстановление мышц на 60%."),
                ))
                warnings.append("Low sleep")
                weekly_score -= 10
            elif sleep_quality <= 2:
                recommendations.append(self._rec(
                    "sleep", 2, lang,
                    az=("Yuxu keyfiyyəti aşağıdır", "Yatmadan 1 saat əvvəl telefonu burax. Otağı 18-20°C-də saxla. Lavanta yağı kömək edə bilər."),
                    en=("Poor sleep quality", "Put phone away 1h before bed. Keep room at 18-20°C. Lavender oil may help."),
                    ru=("Плохое качество сна", "Уберите телефон за 1ч до сна. Температура 18-20°C. Лавандовое масло может помочь."),
                ))
                weekly_score -= 5

            stress = survey_data.get("stress_level", 3)
            if stress >= 4:
                recommendations.append(self._rec(
                    "rest", 1, lang,
                    az=(f"Stress: {stress}/5 — yüksək ⚠️", "10 dəqiqəlik nəfəs məşqi et: 4 saniyə nəfəs al, 4 saxla, 4 burax. Stress kortizolu artırır, arıqlamağı çətinləşdirir."),
                    en=(f"Stress: {stress}/5 — high ⚠️", "Try 10-min breathing: inhale 4s, hold 4s, exhale 4s. Stress raises cortisol and slows fat loss."),
                    ru=(f"Стресс: {stress}/5 — высокий ⚠️", "Попробуйте дыхание 4-4-4 на 10 мин. Стресс повышает кортизол и замедляет похудение."),
                ))
                warnings.append("High stress")
                weekly_score -= 10

            soreness = survey_data.get("muscle_soreness", 3)
            if soreness >= 4:
                recommendations.append(self._rec(
                    "rest", 2, lang,
                    az=(f"Əzələ ağrısı: {soreness}/5", "Bu gün yüngül stretching et, ağır məşqdən qaç. 20 dəqiqə yürüyüş qan dövranını artırıb bərpanı sürətləndirir."),
                    en=(f"Muscle soreness: {soreness}/5", "Do light stretching today, skip heavy training. 20-min walk improves circulation and speeds recovery."),
                    ru=(f"Мышечная боль: {soreness}/5", "Сегодня лёгкая растяжка, без тяжёлых нагрузок. 20 мин ходьбы улучшит кровообращение."),
                ))
                weekly_score -= 5

            energy = survey_data.get("energy_level", 3)
            mood = survey_data.get("mood", 3)
            if energy >= 4 and mood >= 4:
                weekly_score += 5

        weekly_score = max(0, min(100, weekly_score))

        # ── Weekly Comparison ──
        weekly_comparison = self._calc_weekly_comparison(user_data, prev_week_data)

        # ── Time-Based Tip ──
        time_based_tip = self._generate_time_tip(
            lang, workout_count, daily_avg_cal, target_cal, survey_data
        )

        # ── Summary ──
        summary = self._generate_summary(weekly_score, workout_count, daily_avg_cal, target_cal, total_min, lang)

        return {
            "summary": summary,
            "nutrition_tips": nutrition_tips[:3],
            "workout_tips": workout_tips[:3],
            "warnings": warnings[:3],
            "weekly_score": weekly_score,
            "recommendations": recommendations,
            "weekly_comparison": weekly_comparison,
            "time_based_tip": time_based_tip,
        }

    # ──────────────────────────────────────────────
    # TRAINER RECOMMENDATIONS
    # ──────────────────────────────────────────────

    def generate_trainer_recommendations(
        self, students_data: List[Dict], language: str = "az"
    ) -> List[Dict]:
        """Trainer ucun telebe analizi tovsiyyeleri"""
        lang = language if language in ("az", "en", "ru") else "az"
        recs = []

        inactive_students = []
        no_plan_students = []
        high_progress_students = []

        for s in students_data:
            name = s.get("name", "Tələbə")
            week_workouts = s.get("this_week_workouts", 0)
            total_workouts = s.get("total_workouts", 0)
            training_plans = s.get("training_plans_count", 0)
            meal_plans = s.get("meal_plans_count", 0)
            weight = s.get("weight")
            goal = s.get("goal", "")

            if week_workouts == 0:
                inactive_students.append(name)
            if training_plans == 0 and meal_plans == 0:
                no_plan_students.append(name)
            if week_workouts >= 4:
                high_progress_students.append(name)

        # Aktiv olmayan telebeler
        if inactive_students:
            names = ", ".join(inactive_students[:3])
            count = len(inactive_students)
            extra = f" (+{count - 3} daha)" if count > 3 else ""
            recs.append(self._rec(
                "workout", 1, lang,
                az=(f"{count} tələbən bu həftə məşq etməyib", f"{names}{extra} — onlara mesaj göndər və ya yeni plan təyin et."),
                en=(f"{count} students haven't trained this week", f"{names}{extra} — send them a message or assign a new plan."),
                ru=(f"{count} учеников не тренировались", f"{names}{extra} — отправьте сообщение или назначьте план."),
            ))

        # Plani olmayan telebeler
        if no_plan_students:
            names = ", ".join(no_plan_students[:3])
            count = len(no_plan_students)
            extra = f" (+{count - 3} daha)" if count > 3 else ""
            recs.append(self._rec(
                "meal", 2, lang,
                az=(f"{count} tələbənin planı yoxdur", f"{names}{extra} üçün məşq və ya qida planı yarat."),
                en=(f"{count} students have no plans", f"Create workout or meal plans for {names}{extra}."),
                ru=(f"У {count} учеников нет планов", f"Создайте планы для {names}{extra}."),
            ))

        # Yaxsi irəliliyən telebeler
        if high_progress_students:
            names = ", ".join(high_progress_students[:3])
            recs.append(self._rec(
                "workout", 3, lang,
                az=(f"{len(high_progress_students)} tələbə əla irəliləyir 🌟", f"{names} bu həftə 4+ məşq edib. Planlarını yeniləyib intensivliyi artırmağı düşün."),
                en=(f"{len(high_progress_students)} students excelling 🌟", f"{names} did 4+ workouts. Consider updating their plans with higher intensity."),
                ru=(f"{len(high_progress_students)} учеников отлично прогрессируют 🌟", f"{names} сделали 4+ тренировок. Обновите планы с повышенной нагрузкой."),
            ))

        # Umumi statistika
        total = len(students_data)
        active = total - len(inactive_students)
        if total > 0:
            recs.append(self._rec(
                "rest", 3, lang,
                az=(f"Ümumi: {active}/{total} tələbə aktivdir", f"Aktivlik nisbəti: {active * 100 // total}%. Hədəf 80%+ aktivlikdir."),
                en=(f"Overall: {active}/{total} students active", f"Activity rate: {active * 100 // total}%. Target is 80%+."),
                ru=(f"Итого: {active}/{total} учеников активны", f"Активность: {active * 100 // total}%. Цель 80%+."),
            ))

        return recs

    # ──────────────────────────────────────────────
    # HELPERS
    # ──────────────────────────────────────────────

    @staticmethod
    def _rec(rec_type: str, priority: int, lang: str, **texts) -> Dict:
        """Dil esasli tovsiye yaratma helper"""
        t = texts.get(lang, texts.get("az", ("", "")))
        return {
            "type": rec_type,
            "priority": priority,
            "title": t[0],
            "description": t[1],
        }

    @staticmethod
    def _calc_weekly_comparison(
        current_data: Dict, prev_week_data: Optional[Dict]
    ) -> Optional[Dict]:
        """Bu hefte vs kecen hefte muqayisesi"""
        if not prev_week_data:
            return None

        curr_wk = current_data.get("heftelik_mesq", {})
        prev_wk = prev_week_data.get("heftelik_mesq", {})
        curr_fd = current_data.get("heftelik_qidalanma", {})
        prev_fd = prev_week_data.get("heftelik_qidalanma", {})

        curr_workouts = curr_wk.get("mesq_sayi", 0)
        prev_workouts = prev_wk.get("mesq_sayi", 0)
        curr_cal = curr_fd.get("gunluk_ortalama_kalori", 0)
        prev_cal = prev_fd.get("gunluk_ortalama_kalori", 0)
        curr_protein = curr_fd.get("umumi_protein", 0) / 7 if curr_fd.get("umumi_protein", 0) > 0 else 0

        return {
            "workout_change": curr_workouts - prev_workouts,
            "calorie_change": curr_cal - prev_cal,
            "protein_avg": round(curr_protein, 1),
        }

    @staticmethod
    def _generate_time_tip(
        lang: str,
        workout_count: int,
        daily_avg_cal: int,
        target_cal: int,
        survey_data: Optional[Dict],
    ) -> Optional[Dict]:
        """Gun hissesine gore tovsiye"""
        hour = datetime.utcnow().hour + 4  # Baku timezone UTC+4
        if hour >= 24:
            hour -= 24

        if 5 <= hour < 12:
            # Sehher
            water = survey_data.get("water_glasses", 0) if survey_data else 0
            tips = {
                "az": {"type": "hydration", "priority": 2, "title": "Səhər suyu! ☀️", "description": f"Günə 2 stəkan su ilə başla. Dünən {water} stəkan içmisən — bu gün daha yaxşı et."},
                "en": {"type": "hydration", "priority": 2, "title": "Morning water! ☀️", "description": f"Start with 2 glasses of water. Yesterday you had {water} — do better today."},
                "ru": {"type": "hydration", "priority": 2, "title": "Утренняя вода! ☀️", "description": f"Начните с 2 стаканов воды. Вчера было {water} — сегодня больше."},
            }
            return tips.get(lang, tips["az"])

        elif 12 <= hour < 18:
            # Gunorta
            cal_left = max(0, target_cal - daily_avg_cal) if daily_avg_cal > 0 else target_cal
            tips = {
                "az": {"type": "meal", "priority": 2, "title": "Günortadan sonra qidalanma", "description": f"Bu günə {target_cal} kcal hədəfin var. Protein ağırlıqlı nahar et — toyuq, düyü, tərəvəz."},
                "en": {"type": "meal", "priority": 2, "title": "Afternoon nutrition", "description": f"Today's target: {target_cal} kcal. Have a protein-rich lunch — chicken, rice, veggies."},
                "ru": {"type": "meal", "priority": 2, "title": "Обеденное питание", "description": f"Цель на сегодня: {target_cal} kcal. Белковый обед — курица, рис, овощи."},
            }
            return tips.get(lang, tips["az"])

        else:
            # Axsham
            sleep_hours = survey_data.get("sleep_hours", 7) if survey_data else 7
            tips = {
                "az": {"type": "sleep", "priority": 2, "title": "Yuxuya hazırlıq 🌙", "description": f"Dünən {sleep_hours} saat yatmısan. Bu gün 23:00-da yatmağı planla. Ekranlardan 1 saat əvvəl uzaqlaş."},
                "en": {"type": "sleep", "priority": 2, "title": "Sleep preparation 🌙", "description": f"Last night: {sleep_hours}h sleep. Plan to sleep by 11 PM. Avoid screens 1h before bed."},
                "ru": {"type": "sleep", "priority": 2, "title": "Подготовка ко сну 🌙", "description": f"Вчера: {sleep_hours}ч сна. Планируйте лечь в 23:00. Без экранов за 1ч до сна."},
            }
            return tips.get(lang, tips["az"])

    @staticmethod
    def _generate_summary(
        score: int, workouts: int, daily_cal: int, target_cal: int, total_min: int, lang: str
    ) -> str:
        """Reqemli xulase"""
        cal_str = f", gündəlik {daily_cal} kcal" if daily_cal > 0 else ""
        cal_en = f", daily {daily_cal} kcal" if daily_cal > 0 else ""
        cal_ru = f", {daily_cal} kcal/день" if daily_cal > 0 else ""

        s = {
            "az": {
                80: f"Əla gedirsən! {workouts} məşq, {total_min} dəqiqə{cal_str}. Davam et! 🔥",
                60: f"Yaxşı irəliləyirsən. {workouts} məşq, {total_min} dəq{cal_str}.",
                40: f"Orta səviyyədəsən. {workouts} məşq{cal_str}. Daha yaxşı edə bilərsən!",
                0: f"İnkişaf lazımdır. {workouts} məşq{cal_str}. Rejimi yenidən nəzərdən keçir.",
            },
            "en": {
                80: f"Excellent! {workouts} workouts, {total_min} min{cal_en}. Keep it up! 🔥",
                60: f"Good progress. {workouts} workouts, {total_min} min{cal_en}.",
                40: f"Average. {workouts} workouts{cal_en}. You can do better!",
                0: f"Improvement needed. {workouts} workouts{cal_en}.",
            },
            "ru": {
                80: f"Отлично! {workouts} тренировок, {total_min} мин{cal_ru}. 🔥",
                60: f"Хороший прогресс. {workouts} тренировок, {total_min} мин{cal_ru}.",
                40: f"Средний уровень. {workouts} тренировок{cal_ru}.",
                0: f"Нужны улучшения. {workouts} тренировок{cal_ru}.",
            },
        }
        ls = s.get(lang, s["az"])
        if score >= 80:
            return ls[80]
        elif score >= 60:
            return ls[60]
        elif score >= 40:
            return ls[40]
        else:
            return ls[0]
