#!/usr/bin/env python3
"""
Demo user və test data yaradır
"""

import asyncio
import sys
from datetime import datetime, timedelta
from app.database import AsyncSessionLocal
from app.utils.security import hash_password
from app.models.user import User
from app.models.property import Property
from app.models.client import Client
from app.models.activity import Activity
from app.models.deal import Deal
from sqlalchemy import select

async def create_demo_data():
    """Demo data yaradır"""
    async with AsyncSessionLocal() as db:
        try:
            print("🚀 Demo data yaradılır...")

            # Demo user yarat
            demo_email = "demo@emlakcrm.az"
            result = await db.execute(select(User).filter(User.email == demo_email))
            existing_user = result.scalar_one_or_none()

            if existing_user:
                print(f"✅ Demo user artıq mövcuddur: {demo_email}")
                user = existing_user
            else:
                user = User(
                    email=demo_email,
                    hashed_password=hash_password("demo123"),
                    full_name="Demo İstifadəçi",
                    is_active=True,
                    is_superuser=False
                )
                db.add(user)
                await db.commit()
                await db.refresh(user)
                print(f"✅ Demo user yaradıldı: {demo_email} / demo123")

            # Clients yarat
            clients_data = [
            {
                "name": "Rəşad Məmmədov",
                "email": "reshad@example.com",
                "phone": "+994501234567",
                "client_type": "buyer",
                "source": "website",
                "lead_status": "contacted",
                "notes": "3 otaqlı mənzil axtarır"
            },
            {
                "name": "Günay Həsənova",
                "email": "gunay@example.com",
                "phone": "+994551234567",
                "client_type": "seller",
                "source": "referral",
                "lead_status": "negotiating",
                "notes": "Yasamalda mənzil satır"
            },
            {
                "name": "Elçin Quliyev",
                "email": "elchin@example.com",
                "phone": "+994701234567",
                "client_type": "renter",
                "source": "direct_call",
                "lead_status": "new",
                "notes": "Ofis kirayəsi axtarır"
            },
            {
                "name": "Səbinə Əliyeva",
                "email": "sabina@example.com",
                "phone": "+994771234567",
                "client_type": "landlord",
                "source": "social_media",
                "lead_status": "deal_closed",
                "notes": "Nərimanovda 2 mənzili var"
            }
            ]

            clients = []
            for client_data in clients_data:
                client = Client(
                    **client_data,
                    agent_id=user.id
                )
                db.add(client)
                clients.append(client)

            await db.commit()
            print(f"✅ {len(clients)} müştəri yaradıldı")

            # Properties yarat
            properties_data = [
            {
                "title": "Yasamalda 3 otaqlı mənzil",
                "description": "Yeni tikili, təmirli, əlverişli yerləşmə",
                "property_type": "apartment",
                "deal_type": "sale",
                "status": "available",
                "price": 150000,
                "area_sqm": 85,
                "address": "Yasamal rayonu, H.Cavid prospekti 123",
                "city": "Bakı",
                "rooms": 3,
                "bathrooms": 2,
                "floor": 5
            },
            {
                "title": "Nərimanovda villa",
                "description": "3 mərtəbəli, hovuzu var, geniş həyət",
                "property_type": "house",
                "deal_type": "sale",
                "status": "available",
                "price": 450000,
                "area_sqm": 300,
                "address": "Nərimanov rayonu, 8-ci kilometr",
                "city": "Bakı",
                "rooms": 5,
                "bathrooms": 4,
                "floor": 3
            },
            {
                "title": "28 May metrosu yaxınlığında ofis",
                "description": "Kommersiya mərkəzində, təmirli",
                "property_type": "office",
                "deal_type": "rent",
                "status": "available",
                "price": 2000,
                "area_sqm": 120,
                "address": "28 May metrosu, Nizami küçəsi",
                "city": "Bakı",
                "rooms": None,
                "bathrooms": 1,
                "floor": 3
            },
            {
                "title": "Nəsimidə 2 otaqlı mənzil",
                "description": "Köhnə tikili, təmirli, metro yaxın",
                "property_type": "apartment",
                "deal_type": "rent",
                "status": "rented",
                "price": 800,
                "area_sqm": 65,
                "address": "Nəsimi rayonu, Azadlıq prospekti",
                "city": "Bakı",
                "rooms": 2,
                "bathrooms": 1,
                "floor": 4
            },
            {
                "title": "Binəqədidə torpaq sahəsi",
                "description": "İnşaat üçün, bütün kommunikasiyalar var",
                "property_type": "land",
                "deal_type": "sale",
                "status": "available",
                "price": 80000,
                "area_sqm": 600,
                "address": "Binəqədi rayonu, Xocalı prospekti",
                "city": "Bakı",
                "rooms": None,
                "bathrooms": None,
                "floor": None
            }
            ]

            properties = []
            for prop_data in properties_data:
                prop = Property(
                    **prop_data,
                    agent_id=user.id
                )
                db.add(prop)
                properties.append(prop)

            await db.commit()
            print(f"✅ {len(properties)} əmlak yaradıldı")

            # Activities yarat
            activities_data = [
            {
                "activity_type": "call",
                "title": "Rəşad Məmmədov ilə zəng",
                "description": "Yasamaldakı mənzili göstərmək haqqında danışdıq",
                "property_id": properties[0].id,
                "client_id": clients[0].id,
                "scheduled_at": datetime.utcnow() + timedelta(days=1),
                "completed_at": None
            },
            {
                "activity_type": "meeting",
                "title": "Villa baxışı",
                "description": "Müştəri ilə Nərimanovdakı villaya baxış",
                "property_id": properties[1].id,
                "client_id": clients[1].id,
                "scheduled_at": datetime.utcnow() + timedelta(days=2),
                "completed_at": None
            },
            {
                "activity_type": "viewing",
                "title": "Ofis göstərilməsi",
                "description": "28 May metrosunda ofis göstərildi",
                "property_id": properties[2].id,
                "client_id": clients[2].id,
                "scheduled_at": datetime.utcnow() - timedelta(days=1),
                "completed_at": datetime.utcnow()
            },
            {
                "activity_type": "email",
                "title": "Səbinəyə email",
                "description": "Torpaq sahəsi haqqında məlumat göndərildi",
                "property_id": properties[4].id,
                "client_id": clients[3].id,
                "scheduled_at": None,
                "completed_at": datetime.utcnow() - timedelta(hours=5)
            }
            ]

            for activity_data in activities_data:
                activity = Activity(
                    **activity_data,
                    agent_id=user.id
                )
                db.add(activity)

            await db.commit()
            print(f"✅ {len(activities_data)} fəaliyyət yaradıldı")

            # Deals yarat
            deals_data = [
            {
                "notes": "Yasamal mənzil satışı - Rəşad Məmmədov 3 otaqlı mənzil alır",
                "agreed_price": 150000,
                "status": "in_progress",
                "property_id": properties[0].id,
                "client_id": clients[0].id
            },
            {
                "notes": "Villa satışı - Nərimanov villanın satışı",
                "agreed_price": 450000,
                "status": "pending",
                "property_id": properties[1].id,
                "client_id": clients[1].id
            },
            {
                "notes": "Ofis kirayəsi - 28 May ofis kirayə verildi",
                "agreed_price": 24000,  # İllik
                "status": "completed",
                "property_id": properties[2].id,
                "client_id": clients[2].id
            },
            {
                "notes": "Torpaq sahəsi - Binəqədi torpaq sahəsi",
                "agreed_price": 80000,
                "status": "pending",
                "property_id": properties[4].id,
                "client_id": clients[3].id
            }
            ]

            for deal_data in deals_data:
                deal = Deal(
                    **deal_data,
                    agent_id=user.id
                )
                db.add(deal)

            await db.commit()
            print(f"✅ {len(deals_data)} sövdələşmə yaradıldı")

            print("\n" + "="*60)
            print("🎉 Demo data uğurla yaradıldı!")
            print("="*60)
            print(f"\n📧 Email: {demo_email}")
            print(f"🔑 Şifrə: demo123")
            print(f"\n📊 Statistika:")
            print(f"   • {len(clients)} müştəri")
            print(f"   • {len(properties)} əmlak")
            print(f"   • {len(activities_data)} fəaliyyət")
            print(f"   • {len(deals_data)} sövdələşmə")
            print("\n💡 Mobil app-də bu məlumatlarla giriş edə bilərsiniz!")
            print("="*60 + "\n")

        except Exception as e:
            print(f"\n❌ Xəta baş verdi: {str(e)}")
            await db.rollback()
            sys.exit(1)

if __name__ == "__main__":
    asyncio.run(create_demo_data())
