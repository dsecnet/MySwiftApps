#!/usr/bin/env python3
import asyncio
from app.database import AsyncSessionLocal
from app.utils.security import hash_password
from app.models.user import User
from app.models.property import Property
from app.models.client import Client
from sqlalchemy import select

async def main():
    async with AsyncSessionLocal() as db:
        try:
            print("🚀 Demo data yaradılır...")
            
            # Demo user
            demo_email = "demo@emlakcrm.az"
            result = await db.execute(select(User).filter(User.email == demo_email))
            user = result.scalar_one_or_none()
            
            if not user:
                user = User(
                    email=demo_email,
                    hashed_password=hash_password("demo123"),
                    name="Demo İstifadəçi",
                    role="agent",
                    is_active=True
                )
                db.add(user)
                await db.commit()
                await db.refresh(user)
                print(f"✅ User yaradıldı: {demo_email} / demo123")
            else:
                print(f"✅ User artıq mövcuddur: {demo_email}")
            
            # Clients
            clients_created = 0
            for i in range(5):
                client = Client(
                    name=f"Müştəri {i+1}",
                    email=f"client{i+1}@test.com",
                    phone=f"+99450123456{i}",
                    client_type=["buyer", "seller", "tenant", "landlord", "buyer"][i],
                    source=["website", "referral", "direct_call", "social_media", "website"][i],
                    status="active",
                    notes=f"Test müştəri {i+1}",
                    created_by=user.id
                )
                db.add(client)
                clients_created += 1
            await db.commit()
            print(f"✅ {clients_created} müştəri yaradıldı")
            
            # Properties  
            props_created = 0
            props_data = [
                {"title": "Yasamalda 3 otaqlı mənzil", "type": "apartment", "price": 150000, "area": 85},
                {"title": "Nərimanovda villa", "type": "villa", "price": 450000, "area": 300},
                {"title": "28 May ofis", "type": "office", "price": 2000, "area": 120},
                {"title": "Nəsimidə 2 otaqlı", "type": "apartment", "price": 800, "area": 65},
                {"title": "Binəqədidə torpaq", "type": "land", "price": 80000, "area": 600},
            ]
            
            for i, prop_data in enumerate(props_data):
                prop = Property(
                    title=prop_data["title"],
                    property_type=prop_data["type"],
                    listing_type=["sale", "sale", "rent", "rent", "sale"][i],
                    status=["active", "active", "active", "rented", "active"][i],
                    price=prop_data["price"],
                    area=prop_data["area"],
                    address=f"Bakı şəhəri, ünvan {i+1}",
                    city="Bakı",
                    bedrooms=[3, 5, None, 2, None][i],
                    bathrooms=[2, 4, 1, 1, None][i],
                    description=f"{prop_data['title']} - ətraflı məlumat",
                    created_by=user.id
                )
                db.add(prop)
                props_created += 1
            await db.commit()
            print(f"✅ {props_created} əmlak yaradıldı")
            
            print("\n" + "="*60)
            print("🎉 DEMO DATA UĞURLA YARADILDI!")
            print("="*60)
            print(f"\n📧 Email    : {demo_email}")
            print(f"🔑 Şifrə    : demo123")
            print(f"\n📊 Yaradılan data:")
            print(f"   • {clients_created} müştəri")
            print(f"   • {props_created} əmlak")
            print(f"\n💡 iOS app-də bu məlumatlarla login olun!")
            print("="*60 + "\n")
            
        except Exception as e:
            print(f"\n❌ Xəta: {e}")
            import traceback
            traceback.print_exc()
            await db.rollback()

if __name__ == "__main__":
    asyncio.run(main())
