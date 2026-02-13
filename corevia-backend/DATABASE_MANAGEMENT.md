# 🗄️ CoreVia Database Management Guide

## Architecture

```
┌─────────────────────────────────────┐
│   Hetzner Cloud VM (CPX11)          │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │   Backend    │  │ PostgreSQL  │ │
│  │  (FastAPI)   │──│   Database  │ │
│  │  Port 8000   │  │  Port 5432  │ │
│  └──────────────┘  └─────────────┘ │
│         │                           │
│         │ localhost                 │
│  ┌──────▼──────┐                    │
│  │    Nginx    │                    │
│  │  Port 80/443│                    │
│  └─────────────┘                    │
└─────────────────────────────────────┘
           │
           │ Internet
           │
      🌐 api.corevia.life
```

**Benefits of same-server setup:**
- ✅ Zero network latency (localhost connection)
- ✅ No external database costs
- ✅ Simpler configuration
- ✅ Better security (no external ports)
- ✅ Lower cost

---

## Database Configuration

### Connection Details

```env
# In .env file
DATABASE_URL=postgresql+asyncpg://corevia_user:PASSWORD@localhost:5432/corevia_production

# Breakdown:
# - Protocol: postgresql+asyncpg
# - User: corevia_user
# - Password: AUTO_GENERATED (see /tmp/db_password.txt)
# - Host: localhost (same server!)
# - Port: 5432 (PostgreSQL default)
# - Database: corevia_production
```

### PostgreSQL Optimizations Applied

The deployment script automatically configures PostgreSQL for optimal performance:

```ini
max_connections = 100           # Max concurrent connections
shared_buffers = 256MB          # Memory for caching
effective_cache_size = 1GB      # OS cache estimate
work_mem = 2.6MB               # Per-query memory
max_wal_size = 4GB             # Write-ahead log size
```

---

## Common Operations

### 1. Connect to Database

```bash
# As postgres user
sudo -u postgres psql corevia_production

# Or with password
psql -h localhost -U corevia_user -d corevia_production
```

### 2. Check Database Status

```bash
# Test connection
./test-database.sh

# PostgreSQL status
sudo systemctl status postgresql

# Check if listening
sudo netstat -tlnp | grep 5432
```

### 3. View Tables

```sql
-- Connect to database
sudo -u postgres psql corevia_production

-- List all tables
\dt

-- Describe a table
\d users

-- Count rows
SELECT COUNT(*) FROM users;
```

### 4. Backup Database

```bash
# Manual backup (runs automatically at 3 AM daily)
./backup-database.sh

# Manual backup with custom name
sudo -u postgres pg_dump corevia_production > backup_$(date +%Y%m%d).sql

# Compressed backup
sudo -u postgres pg_dump corevia_production | gzip > backup.sql.gz
```

### 5. Restore Database

```bash
# From SQL file
sudo -u postgres psql corevia_production < backup_20240115.sql

# From compressed backup
gunzip -c backup.sql.gz | sudo -u postgres psql corevia_production

# Drop and recreate (DANGER!)
sudo -u postgres dropdb corevia_production
sudo -u postgres createdb corevia_production -O corevia_user
sudo -u postgres psql corevia_production < backup.sql
```

### 6. Database Migrations

```bash
# Check current migration
cd /var/www/corevia
source venv/bin/activate
alembic current

# Run pending migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Create new migration
alembic revision --autogenerate -m "Add new table"
```

---

## Monitoring

### Database Size

```sql
-- Total database size
SELECT pg_size_pretty(pg_database_size('corevia_production'));

-- Table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Active Connections

```sql
-- Current connections
SELECT count(*) FROM pg_stat_activity
WHERE datname = 'corevia_production';

-- Detailed connection info
SELECT pid, usename, application_name, client_addr, state, query
FROM pg_stat_activity
WHERE datname = 'corevia_production';
```

### Database Performance

```sql
-- Slow queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 seconds'
  AND state = 'active';

-- Cache hit ratio (should be > 99%)
SELECT
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100 as ratio
FROM pg_statio_user_tables;
```

---

## Backup Strategy

### Automatic Backups

Deployed via cron (3 AM daily):
```bash
0 3 * * * /var/www/corevia/backup-database.sh >> /var/log/corevia-backup.log 2>&1
```

**Retention:** 7 days (automatically deletes older backups)

**Location:** `/var/backups/corevia/`

### Backup Verification

```bash
# List all backups
ls -lh /var/backups/corevia/

# Check backup log
tail -f /var/log/corevia-backup.log

# Test restore (dry run)
gunzip -c /var/backups/corevia/corevia_db_LATEST.sql.gz | head -n 100
```

### Off-site Backup (Recommended)

```bash
# Upload to cloud storage
# Option 1: AWS S3
aws s3 cp /var/backups/corevia/ s3://your-backup-bucket/corevia/ --recursive

# Option 2: rsync to another server
rsync -avz /var/backups/corevia/ user@backup-server:/backups/corevia/

# Option 3: Hetzner Storage Box
rsync -avz /var/backups/corevia/ u123456@u123456.your-storagebox.de:/backups/
```

---

## Troubleshooting

### Database Connection Refused

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start if stopped
sudo systemctl start postgresql

# Check logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

### Out of Connections

```sql
-- Check current connections
SELECT count(*) FROM pg_stat_activity;

-- Kill idle connections
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'corevia_production'
  AND state = 'idle'
  AND state_change < current_timestamp - INTERVAL '5 minutes';
```

### Slow Queries

```bash
# Enable query logging
sudo nano /etc/postgresql/*/main/postgresql.conf

# Add/uncomment:
log_min_duration_statement = 1000  # Log queries > 1 second

# Restart
sudo systemctl restart postgresql

# View slow queries
sudo tail -f /var/log/postgresql/postgresql-*.log | grep "duration:"
```

### Disk Space Issues

```bash
# Check disk usage
df -h

# Database size
sudo -u postgres psql -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) FROM pg_database;"

# Clean old backups
find /var/backups/corevia/ -name "*.sql.gz" -mtime +7 -delete

# Vacuum database (reclaim space)
sudo -u postgres vacuumdb --all --analyze
```

---

## Security

### Database Access

PostgreSQL is configured to:
- ✅ Only listen on `localhost` (not accessible from internet)
- ✅ Strong password generated automatically
- ✅ User has limited privileges (only corevia_production DB)

### Check Configuration

```bash
# PostgreSQL listening addresses
sudo grep "listen_addresses" /etc/postgresql/*/main/postgresql.conf
# Should be: listen_addresses = 'localhost'

# Connection settings
sudo cat /etc/postgresql/*/main/pg_hba.conf
```

### Change Database Password

```sql
-- As postgres user
sudo -u postgres psql

-- Change password
ALTER USER corevia_user WITH PASSWORD 'new_strong_password';

-- Then update .env file:
nano /var/www/corevia/.env
# Update DATABASE_URL with new password

-- Restart backend
sudo supervisorctl restart corevia
```

---

## Performance Tuning

### Analyze Tables

```sql
-- Update statistics
ANALYZE;

-- Vacuum and analyze
VACUUM ANALYZE;

-- Full vacuum (reclaim space)
VACUUM FULL;
```

### Create Indexes

```sql
-- Example: Index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);

-- Check existing indexes
\di

-- Drop index
DROP INDEX idx_users_email;
```

### Query Optimization

```sql
-- Explain query plan
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public'
ORDER BY abs(correlation) ASC
LIMIT 10;
```

---

## Useful Scripts

### Quick Status Check

```bash
#!/bin/bash
echo "🗄️ Database Status"
echo "=================="
sudo systemctl status postgresql --no-pager
echo ""
echo "Connections: $(sudo -u postgres psql -t -c "SELECT count(*) FROM pg_stat_activity WHERE datname='corevia_production';")"
echo "Size: $(sudo -u postgres psql -t -c "SELECT pg_size_pretty(pg_database_size('corevia_production'));")"
echo "Latest backup: $(ls -t /var/backups/corevia/ | head -1)"
```

### Database Health Check

```bash
./test-database.sh
```

---

## Migration from Development to Production

```bash
# 1. Dump development database
pg_dump -U postgres corevia_db > dev_dump.sql

# 2. Upload to server
scp dev_dump.sql root@api.corevia.life:/tmp/

# 3. Restore on production
ssh root@api.corevia.life
sudo -u postgres psql corevia_production < /tmp/dev_dump.sql

# 4. Run migrations
cd /var/www/corevia
source venv/bin/activate
alembic upgrade head

# 5. Restart backend
sudo supervisorctl restart corevia
```

---

## Summary

✅ **Backend + Database on same server**
✅ **PostgreSQL on localhost:5432**
✅ **Automatic daily backups (3 AM)**
✅ **Optimized configuration**
✅ **Secure (localhost only)**
✅ **Monitoring scripts included**

**Database password:** Check `/tmp/db_password.txt` after deployment

**Backups location:** `/var/backups/corevia/`

**Commands:**
- Test: `./test-database.sh`
- Backup: `./backup-database.sh`
- Connect: `sudo -u postgres psql corevia_production`
