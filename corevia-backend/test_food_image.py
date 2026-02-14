import asyncio
import base64
from app.services.ai_food_service import ai_food_service

async def test():
    # 1x1 pixel red JPEG (minimal test image)
    test_image_b64 = "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA//2Q=="
    
    result = await ai_food_service.analyze_food_image(
        image_base64=test_image_b64,
        language="az"
    )
    
    print("🧪 AI Food Analysis Test Result:")
    print(f"   Success: {result.get('success')}")
    print(f"   Food: {result.get('food_name', 'N/A')}")
    print(f"   Calories: {result.get('calories', 0)}")
    print(f"   Protein: {result.get('protein', 0)}g")
    print(f"   Carbs: {result.get('carbs', 0)}g")
    print(f"   Fats: {result.get('fats', 0)}g")
    if result.get('error'):
        print(f"   Error: {result.get('error')}")

asyncio.run(test())
