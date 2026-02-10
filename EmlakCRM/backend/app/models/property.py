from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, Text, JSON, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
import uuid

from app.database import Base


class PropertyType(str, enum.Enum):
    apartment = "apartment"  # Mənzil
    house = "house"  # Ev/Villa
    land = "land"  # Torpaq
    commercial = "commercial"  # Kommersiya
    office = "office"  # Ofis


class PropertyStatus(str, enum.Enum):
    available = "available"  # Satılıq/Kirayə
    reserved = "reserved"  # Rezerv
    sold = "sold"  # Satılıb
    rented = "rented"  # Kirayələnib
    archived = "archived"  # Arxiv


class DealType(str, enum.Enum):
    sale = "sale"  # Satış
    rent = "rent"  # Kirayə


class Property(Base):
    __tablename__ = "properties"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    agent_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Basic Info
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    property_type = Column(SAEnum(PropertyType), nullable=False)
    deal_type = Column(SAEnum(DealType), nullable=False)
    status = Column(SAEnum(PropertyStatus), default=PropertyStatus.available, nullable=False)

    # Location
    city = Column(String(100), default="Bakı", nullable=False)
    district = Column(String(100), nullable=True)  # Nəsimi, Yasamal
    address = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)  # GPS koordinat
    longitude = Column(Float, nullable=True)  # GPS koordinat
    nearest_metro = Column(String(100), nullable=True)  # Ən yaxın metro
    metro_distance_m = Column(Integer, nullable=True)  # Metroya məsafə (metr)
    nearby_landmarks = Column(JSON, nullable=True)  # Yaxınlıqdakı məkanlar: [{"name": "28 May", "type": "metro", "distance": 500}]

    # Details
    price = Column(Float, nullable=False)
    currency = Column(String(10), default="AZN")
    area_sqm = Column(Float, nullable=True)  # m²
    rooms = Column(Integer, nullable=True)  # Otaq sayı
    bathrooms = Column(Integer, nullable=True)
    floor = Column(Integer, nullable=True)
    total_floors = Column(Integer, nullable=True)

    # Features (JSON array)
    features = Column(JSON, nullable=True)  # ["Təmir", "Mebel", "Kondisioner"]

    # Media
    images = Column(JSON, nullable=True)  # ["url1", "url2"]
    video_url = Column(String(500), nullable=True)
    virtual_tour_url = Column(String(500), nullable=True)

    # Owner Contact (optional)
    owner_name = Column(String(100), nullable=True)
    owner_phone = Column(String(20), nullable=True)

    # Marketing
    featured = Column(Boolean, default=False)  # Xüsusi elan
    views_count = Column(Integer, default=0)
    favorites_count = Column(Integer, default=0)

    # External Platforms
    bina_az_url = Column(String(500), nullable=True)
    tap_az_url = Column(String(500), nullable=True)
    bina_az_id = Column(String(100), nullable=True)
    tap_az_id = Column(String(100), nullable=True)

    # Internal Notes (only visible to agent)
    internal_notes = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    published_at = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<Property {self.title} - {self.price} {self.currency}>"
