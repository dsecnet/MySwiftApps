#!/bin/bash

# ============================================
# CoreVia - PostgreSQL Backup Script
# Eyni serverdə database backup
# ============================================

set -e

# Configuration
BACKUP_DIR="/var/backups/corevia"
DB_NAME="corevia_production"
DB_USER="corevia_user"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/corevia_db_$DATE.sql"
KEEP_DAYS=7  # Keep backups for 7 days

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️  CoreVia Database Backup${NC}"
echo "================================"
echo ""

# Create backup directory
sudo mkdir -p $BACKUP_DIR
sudo chown -R postgres:postgres $BACKUP_DIR

echo -e "${BLUE}Creating backup...${NC}"
sudo -u postgres pg_dump $DB_NAME > $BACKUP_FILE

# Compress backup
echo -e "${BLUE}Compressing backup...${NC}"
gzip $BACKUP_FILE

# Delete old backups
echo -e "${BLUE}Cleaning old backups (older than $KEEP_DAYS days)...${NC}"
find $BACKUP_DIR -name "corevia_db_*.sql.gz" -mtime +$KEEP_DAYS -delete

# Show backup info
BACKUP_SIZE=$(du -h $BACKUP_FILE.gz | cut -f1)
echo ""
echo -e "${GREEN}✅ Backup completed!${NC}"
echo "   File: $BACKUP_FILE.gz"
echo "   Size: $BACKUP_SIZE"
echo ""
echo "Available backups:"
ls -lh $BACKUP_DIR/corevia_db_*.sql.gz

echo ""
echo "To restore:"
echo "  gunzip $BACKUP_FILE.gz"
echo "  sudo -u postgres psql $DB_NAME < $BACKUP_FILE"
