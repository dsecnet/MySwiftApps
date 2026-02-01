import os
import uuid
from pathlib import Path
from fastapi import UploadFile, HTTPException, status
from PIL import Image
import io

from app.config import get_settings

settings = get_settings()

UPLOAD_DIR = Path(__file__).parent.parent.parent / "uploads"
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_IMAGE_DIMENSION = 1024  # px


def _validate_image(file: UploadFile) -> None:
    # Extension yoxla
    ext = Path(file.filename).suffix.lower() if file.filename else ""
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Icaze verilen formatlar: {', '.join(ALLOWED_EXTENSIONS)}",
        )

    # Content type yoxla
    if file.content_type and not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Yalniz sekil fayllari yuklene biler",
        )


def _resize_image(image_data: bytes, max_dim: int = MAX_IMAGE_DIMENSION) -> bytes:
    img = Image.open(io.BytesIO(image_data))

    # EXIF rotation fix
    try:
        from PIL import ImageOps
        img = ImageOps.exif_transpose(img)
    except Exception:
        pass

    # Resize if needed
    if img.width > max_dim or img.height > max_dim:
        img.thumbnail((max_dim, max_dim), Image.LANCZOS)

    # Convert to RGB if RGBA
    if img.mode == "RGBA":
        img = img.convert("RGB")

    output = io.BytesIO()
    img.save(output, format="JPEG", quality=85, optimize=True)
    return output.getvalue()


async def save_upload(file: UploadFile, subfolder: str) -> str:
    """Sekili local-da saxla. Qaytarir: relative path (URL ucun)"""
    _validate_image(file)

    # Fayli oxu
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Fayl 10MB-dan boyuk ola bilmez",
        )

    # Resize ve optimize
    optimized = _resize_image(content)

    # Unique filename
    ext = ".jpg"
    filename = f"{uuid.uuid4()}{ext}"
    folder = UPLOAD_DIR / subfolder
    folder.mkdir(parents=True, exist_ok=True)
    filepath = folder / filename

    # Yaz
    with open(filepath, "wb") as f:
        f.write(optimized)

    # Relative path qaytar (URL-de istifade ucun)
    return f"/uploads/{subfolder}/{filename}"


async def delete_upload(file_path: str) -> None:
    """Lokaldaki sekili sil"""
    if not file_path:
        return

    # /uploads/profiles/xxx.jpg -> uploads/profiles/xxx.jpg
    relative = file_path.lstrip("/")
    full_path = Path(__file__).parent.parent.parent / relative

    if full_path.exists():
        full_path.unlink()
