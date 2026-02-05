# Database Migration - v2.0 Features

## New Tables Added

### Social Features
1. **posts** - Social media posts
2. **post_likes** - Likes on posts
3. **post_comments** - Comments on posts
4. **follows** - Follow relationships
5. **achievements** - User achievements/badges

### Marketplace
6. **marketplace_products** - Products for sale
7. **product_purchases** - Purchase records
8. **product_reviews** - Product reviews

---

## Create Migration

```bash
cd corevia-backend

# Generate migration automatically
alembic revision --autogenerate -m "Add v2.0 social and marketplace tables"

# Review the generated migration file
# File location: alembic/versions/XXXXX_add_v2_0_social_and_marketplace_tables.py

# Apply migration
alembic upgrade head
```

---

## Manual Migration (if autogenerate fails)

If Alembic autogenerate doesn't detect the new models, manually import them:

**File**: `corevia-backend/app/models/__init__.py`

```python
# Add these imports
from app.models.social import Post, PostLike, PostComment, Follow, Achievement
from app.models.marketplace import MarketplaceProduct, ProductPurchase, ProductReview
```

Then run:
```bash
alembic revision --autogenerate -m "Add v2.0 tables"
alembic upgrade head
```

---

## Verify Migration

```bash
# Check current database version
alembic current

# Check migration history
alembic history

# Show SQL that will be executed (without applying)
alembic upgrade head --sql
```

---

## Rollback (if needed)

```bash
# Rollback one migration
alembic downgrade -1

# Rollback to specific version
alembic downgrade <revision_id>

# Rollback all migrations
alembic downgrade base
```

---

## Common Issues

### Issue 1: Models not detected
**Solution**: Import models in `app/models/__init__.py`

### Issue 2: Circular import errors
**Solution**: Import User/Workout/FoodEntry at the bottom of the file

### Issue 3: Enum types already exist
**Solution**: Use `IF NOT EXISTS` or manually handle enum types

---

## Production Deployment

```bash
# Backup database first!
pg_dump corevia_db > backup_before_v2.sql

# Apply migration
alembic upgrade head

# Verify tables created
psql corevia_db -c "\dt"
```
