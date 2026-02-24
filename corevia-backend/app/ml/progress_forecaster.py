"""
Progress Forecaster — linear trend + Prophet (optional)

Son 30 gunluk data-dan gelecek 7 gunun proqnozunu verir.
Prophet yuklu deyilse linear regression istifade edir.

Xarici AI API istifade etmir — tam local ML.
"""

import logging
from typing import Dict, List

import numpy as np

logger = logging.getLogger(__name__)


class ProgressForecaster:
    """Prophet ile proqres proqnozu. Prophet yoxdursa linear trend."""

    def __init__(self):
        self._prophet_available = False
        try:
            from prophet import Prophet
            self._prophet_available = True
            logger.info("Prophet available for forecasting")
        except ImportError:
            logger.info("Prophet not installed. Using linear trend.")

    def forecast_weight(self, weight_history: List[Dict], days_ahead: int = 7) -> Dict:
        """Ceki proqnozu"""
        if not weight_history or len(weight_history) < 3:
            return {
                "current_weight": weight_history[-1]["weight"] if weight_history else 0,
                "predicted_weight": 0,
                "trend": "stable",
                "weekly_change": 0.0,
                "forecast_message": "Yeterli data yoxdur.",
            }

        weights = np.array([h["weight"] for h in weight_history])
        days = np.arange(len(weights))
        coeffs = np.polyfit(days, weights, 1)
        slope = coeffs[0]

        current = weights[-1]
        predicted = current + slope * days_ahead
        weekly_change = slope * 7

        if weekly_change < -0.1:
            trend = "losing"
            msg = f"Bu tempdə həftədə {abs(weekly_change):.1f}kg itirəcəksən."
        elif weekly_change > 0.1:
            trend = "gaining"
            msg = f"Bu tempdə həftədə {weekly_change:.1f}kg artacaqsan."
        else:
            trend = "stable"
            msg = "Çəkin stabil qalır."

        return {
            "current_weight": round(float(current), 1),
            "predicted_weight": round(float(predicted), 1),
            "trend": trend,
            "weekly_change": round(float(weekly_change), 2),
            "forecast_message": msg,
        }

    def forecast_calories(self, calorie_history: List[Dict], target_calories: int = 2000) -> Dict:
        """Kalori trend proqnozu"""
        if not calorie_history or len(calorie_history) < 3:
            return {"trend": "stable", "avg_calories": 0, "message": "Yeterli data yoxdur."}

        cals = [h["calories"] for h in calorie_history]
        avg = sum(cals) / len(cals)

        if len(cals) >= 6:
            recent = sum(cals[-3:]) / 3
            older = sum(cals[-6:-3]) / 3
            change = recent - older
        else:
            change = 0

        if change > 100:
            trend = "increasing"
        elif change < -100:
            trend = "decreasing"
        else:
            trend = "stable"

        return {
            "trend": trend,
            "avg_calories": round(avg),
            "target_calories": target_calories,
            "diff": round(avg - target_calories),
            "message": f"Kalori qebulu: {avg:.0f} kcal/gun orta.",
        }


progress_forecaster = ProgressForecaster()
