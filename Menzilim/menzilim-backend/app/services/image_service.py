import os
import uuid
import logging
from pathlib import Path

import aiofiles
from fastapi import UploadFile, HTTPException, status
from PIL import Image

from app.config import get_settings

settings = get_settings()
logger = logging.getLogger(__name__)


class ImageService:
    """Service for handling image uploads and processing."""

    UPLOAD_BASE = Path(settings.UPLOAD_DIR)

    @staticmethod
    async def upload_image(
        file: UploadFile,
        subdirectory: str = "listings",
    ) -> str:
        """
        Upload and process an image file.
        Returns the relative URL path for the saved image.
        """
        # Validate content type
        if file.content_type not in settings.ALLOWED_IMAGE_TYPES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid image type: {file.content_type}. "
                f"Allowed: {', '.join(settings.ALLOWED_IMAGE_TYPES)}",
            )

        # Read content
        content = await file.read()

        # Validate file size
        if len(content) > settings.MAX_IMAGE_SIZE:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Image too large. Maximum size: {settings.MAX_IMAGE_SIZE // (1024 * 1024)} MB",
            )

        # Generate unique filename
        ext = _get_extension(file.content_type)
        filename = f"{uuid.uuid4().hex}{ext}"

        # Ensure upload directory exists
        upload_dir = ImageService.UPLOAD_BASE / subdirectory
        upload_dir.mkdir(parents=True, exist_ok=True)

        file_path = upload_dir / filename

        # Save file
        async with aiofiles.open(file_path, "wb") as f:
            await f.write(content)

        # Optimize image
        try:
            await ImageService._optimize_image(str(file_path))
        except Exception as e:
            logger.warning(f"Image optimization failed for {filename}: {e}")

        relative_url = f"/{settings.UPLOAD_DIR}/{subdirectory}/{filename}"
        logger.info(f"Image uploaded: {relative_url}")
        return relative_url

    @staticmethod
    async def delete_image(image_url: str) -> bool:
        """Delete an image file by its URL path."""
        try:
            # Strip leading slash
            file_path = Path(image_url.lstrip("/"))
            if file_path.exists():
                os.remove(file_path)
                logger.info(f"Image deleted: {image_url}")
                return True
            return False
        except Exception as e:
            logger.error(f"Failed to delete image {image_url}: {e}")
            return False

    @staticmethod
    async def _optimize_image(file_path: str, max_width: int = 1920) -> None:
        """Optimize image: resize if too large, compress quality."""
        with Image.open(file_path) as img:
            # Convert RGBA to RGB for JPEG
            if img.mode == "RGBA":
                img = img.convert("RGB")

            # Resize if needed
            if img.width > max_width:
                ratio = max_width / img.width
                new_height = int(img.height * ratio)
                img = img.resize((max_width, new_height), Image.LANCZOS)

            # Save with optimization
            if file_path.endswith(".png"):
                img.save(file_path, "PNG", optimize=True)
            else:
                img.save(file_path, "JPEG", quality=85, optimize=True)


def _get_extension(content_type: str) -> str:
    """Get file extension from content type."""
    mapping = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }
    return mapping.get(content_type, ".jpg")


image_service = ImageService()
