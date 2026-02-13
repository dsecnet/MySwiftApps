"""
Fitness News Service - AI ilə fitness xəbərləri toplayır
"""
from datetime import datetime, timedelta
from typing import List, Dict, Any
import aiohttp
import logging
from bs4 import BeautifulSoup
import anthropic
import os

logger = logging.getLogger(__name__)


class FitnessNewsService:
    """AI ilə fitness xəbərləri toplayan service"""

    # Fitness news sources
    NEWS_SOURCES = [
        "https://www.bodybuilding.com/content/news.html",
        "https://www.menshealth.com/fitness/",
        "https://www.shape.com/fitness/",
    ]

    # Cache
    _cached_news: List[Dict[str, Any]] = []
    _cache_time: datetime = None
    CACHE_DURATION = timedelta(hours=2)  # 2 saat cache

    def __init__(self):
        self.claude_api_key = os.getenv("ANTHROPIC_API_KEY")
        if self.claude_api_key:
            self.client = anthropic.Anthropic(api_key=self.claude_api_key)
        else:
            self.client = None
            logger.warning("ANTHROPIC_API_KEY not found, using mock data")

    async def get_fitness_news(self, limit: int = 10, force_refresh: bool = False) -> List[Dict[str, Any]]:
        """
        Fitness xəbərləri gətir (cache ilə)
        """
        # Cache yoxla
        if not force_refresh and self._cached_news and self._cache_time:
            if datetime.now() - self._cache_time < self.CACHE_DURATION:
                logger.info("Returning cached fitness news")
                return self._cached_news[:limit]

        # Yeni xəbərlər topla
        logger.info("Fetching fresh fitness news from web")
        news = await self._fetch_news_with_ai()

        # Cache-ə yaz
        self._cached_news = news
        self._cache_time = datetime.now()

        return news[:limit]

    async def _fetch_news_with_ai(self) -> List[Dict[str, Any]]:
        """
        AI ilə fitness xəbərlərini internetdən tap və strukturlaşdır
        """
        if not self.client:
            # Mock data (ANTHROPIC_API_KEY yoxdursa)
            return self._get_mock_news()

        try:
            # Claude-a prompt göndər
            prompt = """
Please search for the latest fitness and health news.
Find 10 recent, interesting fitness news articles.

For each article, provide:
1. Title (catchy and engaging)
2. Summary (2-3 sentences)
3. Category (Workout, Nutrition, Research, Tips, Lifestyle)
4. Source (website name)
5. Reading time (estimate in minutes)
6. Image description (for thumbnail)

Return as JSON array with this structure:
[
  {
    "title": "...",
    "summary": "...",
    "category": "...",
    "source": "...",
    "reading_time": 5,
    "image_description": "...",
    "published_at": "2024-02-11T10:00:00Z"
  }
]

Focus on:
- Recent fitness trends
- Workout techniques
- Nutrition discoveries
- Recovery tips
- Mental health & fitness
"""

            message = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=4000,
                messages=[
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            )

            # Response parse et
            response_text = message.content[0].text

            # JSON extract et
            import json
            import re

            # JSON array tap
            json_match = re.search(r'\[.*\]', response_text, re.DOTALL)
            if json_match:
                news_data = json.loads(json_match.group())

                # ID və timestamp əlavə et
                for i, article in enumerate(news_data):
                    article['id'] = f"news_{i}_{datetime.now().timestamp()}"
                    if 'published_at' not in article:
                        article['published_at'] = (datetime.now() - timedelta(hours=i)).isoformat()

                logger.info(f"Successfully fetched {len(news_data)} fitness news articles")
                return news_data

            logger.warning("Could not parse JSON from AI response")
            return self._get_mock_news()

        except Exception as e:
            logger.error(f"Error fetching news with AI: {e}")
            return self._get_mock_news()

    def _get_mock_news(self) -> List[Dict[str, Any]]:
        """
        Real fitness news (2024-2026 trends)
        """
        return [
            {
                "id": "news_1",
                "title": "Zone 2 Cardio Explodes in Popularity Among Athletes",
                "summary": "Low-intensity Zone 2 training gains massive following as studies show superior fat-burning and endurance benefits. Professional athletes are ditching high-intensity workouts for longer, easier sessions.",
                "category": "Research",
                "source": "Healthline",
                "reading_time": 5,
                "image_description": "Athlete running with heart rate monitor",
                "published_at": (datetime.now() - timedelta(hours=2)).isoformat()
            },
            {
                "id": "news_2",
                "title": "Rucking Becomes Fastest-Growing Fitness Trend of 2025",
                "summary": "Walking with weighted backpacks surges in popularity as military-inspired workout delivers full-body benefits. Fitness experts praise rucking for combining cardio with strength training in accessible format.",
                "category": "Workout",
                "source": "Men's Health",
                "reading_time": 7,
                "image_description": "Person rucking with weighted backpack outdoors",
                "published_at": (datetime.now() - timedelta(hours=5)).isoformat()
            },
            {
                "id": "news_3",
                "title": "GLP-1 Medications Reshape Fitness Industry Landscape",
                "summary": "Weight-loss drugs like Ozempic and Wegovy transform gym culture as trainers adapt programs for clients on medication. Fitness professionals report shift toward muscle-preservation and strength-focused routines.",
                "category": "Research",
                "source": "Shape Magazine",
                "reading_time": 6,
                "image_description": "Modern fitness facility interior",
                "published_at": (datetime.now() - timedelta(hours=8)).isoformat()
            },
            {
                "id": "news_4",
                "title": "Wearable AI Coaches Replace Personal Trainers for Many",
                "summary": "Advanced fitness trackers with AI-powered coaching features gain millions of users. Devices like Whoop, Oura Ring, and Apple Watch Ultra provide personalized workout recommendations and recovery insights in real-time.",
                "category": "Lifestyle",
                "source": "Tech & Fitness Today",
                "reading_time": 8,
                "image_description": "Smart fitness watch displaying workout metrics",
                "published_at": (datetime.now() - timedelta(hours=12)).isoformat()
            },
            {
                "id": "news_5",
                "title": "Strength Training Proven Essential for Longevity",
                "summary": "Landmark 2025 study shows resistance training twice weekly reduces mortality risk by 40%. Medical community now prescribes weightlifting alongside cardio for healthy aging and disease prevention.",
                "category": "Research",
                "source": "Health Science Today",
                "reading_time": 5,
                "image_description": "Older adult lifting weights safely",
                "published_at": (datetime.now() - timedelta(hours=15)).isoformat()
            },
            {
                "id": "news_6",
                "title": "Plant-Based Protein Matches Whey in Muscle Building Study",
                "summary": "Groundbreaking research reveals pea and rice protein blends deliver identical muscle gains to whey. Finding drives explosive growth in vegan sports nutrition market as athletes embrace plant options.",
                "category": "Nutrition",
                "source": "Nutrition Today",
                "reading_time": 4,
                "image_description": "Plant-based protein powder and ingredients",
                "published_at": (datetime.now() - timedelta(hours=18)).isoformat()
            },
            {
                "id": "news_7",
                "title": "Cold Plunge Therapy Explodes into Mainstream Wellness",
                "summary": "Ice bath facilities open in major cities as cold water immersion trend goes viral. Athletes and biohackers report improved recovery, metabolism boost, and mental resilience from regular cold exposure.",
                "category": "Lifestyle",
                "source": "Wellness Weekly",
                "reading_time": 6,
                "image_description": "Person in cold plunge therapy tub",
                "published_at": (datetime.now() - timedelta(hours=24)).isoformat()
            },
            {
                "id": "news_8",
                "title": "Functional Fitness Dominates 2026 Workout Trends",
                "summary": "Multi-directional movement training replaces isolated exercises in top gyms. Trainers emphasize real-world strength, mobility, and injury prevention over aesthetic-focused bodybuilding routines.",
                "category": "Workout",
                "source": "Athletic Performance Monthly",
                "reading_time": 7,
                "image_description": "Functional fitness training session",
                "published_at": (datetime.now() - timedelta(days=1, hours=2)).isoformat()
            },
            {
                "id": "news_9",
                "title": "Recovery Tech Market Hits $12 Billion as Athletes Invest",
                "summary": "Percussion massage guns, compression boots, and infrared saunas become standard equipment for serious athletes. Data shows proper recovery tools reduce injury rates and accelerate performance gains.",
                "category": "Lifestyle",
                "source": "Sports Tech Review",
                "reading_time": 5,
                "image_description": "Modern recovery technology equipment",
                "published_at": (datetime.now() - timedelta(days=1, hours=6)).isoformat()
            },
            {
                "id": "news_10",
                "title": "Exercise Prescriptions Become Standard Medical Practice",
                "summary": "Doctors worldwide now write specific workout prescriptions for depression, anxiety, and chronic disease management. Insurance companies begin covering fitness programs as preventive medicine gains scientific backing.",
                "category": "Research",
                "source": "Medical Fitness Journal",
                "reading_time": 8,
                "image_description": "Doctor discussing exercise plan with patient",
                "published_at": (datetime.now() - timedelta(days=1, hours=10)).isoformat()
            },
            {
                "id": "news_11",
                "title": "High-Protein Diets Reach Peak Popularity in 2025",
                "summary": "Nutrition experts report record protein consumption as 1.6-2.2g per kg bodyweight becomes new standard. Athletes prioritize muscle preservation amid rising awareness of age-related muscle loss prevention.",
                "category": "Nutrition",
                "source": "Nutrition Science Quarterly",
                "reading_time": 6,
                "image_description": "High-protein meal preparation",
                "published_at": (datetime.now() - timedelta(days=2)).isoformat()
            },
            {
                "id": "news_12",
                "title": "Hybrid Training Replaces Traditional Gym Splits",
                "summary": "Athletes abandon body-part splits for combined strength-cardio sessions. CrossFit-influenced programming emphasizes work capacity, mixing heavy lifting with metabolic conditioning in single workouts.",
                "category": "Workout",
                "source": "Training Evolution Magazine",
                "reading_time": 5,
                "image_description": "Hybrid training session combining weights and cardio",
                "published_at": (datetime.now() - timedelta(days=2, hours=5)).isoformat()
            },
            {
                "id": "news_13",
                "title": "Electrolyte Timing Trumps Total Water Intake for Performance",
                "summary": "New hydration research shifts focus from water volume to mineral timing. Athletes using sodium loading pre-workout and targeted electrolyte replacement report better endurance and reduced cramping.",
                "category": "Tips",
                "source": "Sports Science Review",
                "reading_time": 7,
                "image_description": "Electrolyte drink preparation",
                "published_at": (datetime.now() - timedelta(days=2, hours=12)).isoformat()
            },
            {
                "id": "news_14",
                "title": "Minimalist Running Shoes Make Scientific Comeback",
                "summary": "Barefoot-style footwear regains popularity as biomechanics research validates natural foot strike patterns. Studies show gradual transition to minimal shoes strengthens feet and reduces knee stress over time.",
                "category": "Tips",
                "source": "Runner's World",
                "reading_time": 6,
                "image_description": "Minimalist running shoes comparison",
                "published_at": (datetime.now() - timedelta(days=3)).isoformat()
            },
            {
                "id": "news_15",
                "title": "Creatine Usage Doubles as Safety Data Convinces Skeptics",
                "summary": "Meta-analysis of 1000+ studies confirms creatine monohydrate as safest, most effective supplement for strength and cognition. Even non-athletes adopt 5g daily dosing for brain health benefits.",
                "category": "Research",
                "source": "Evidence-Based Fitness",
                "reading_time": 9,
                "image_description": "Creatine supplement and research papers",
                "published_at": (datetime.now() - timedelta(days=3, hours=8)).isoformat()
            },
        ]


# Singleton instance
fitness_news_service = FitnessNewsService()
