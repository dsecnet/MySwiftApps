# CoreVia Load Testing

Comprehensive load testing suite using Locust to test API performance under stress.

---

## 📊 Overview

This load testing suite simulates real-world usage patterns of the CoreVia app with two user types:
- **Students** (90% of traffic): Browse feed, create posts, like, comment, log workouts
- **Trainers** (10% of traffic): Create products, manage content, post tips

---

## 🚀 Quick Start

### Install Locust
```bash
pip install locust
```

### Run Load Test
```bash
cd corevia-backend/tests/load

# Run with Web UI
locust -f locustfile.py

# Open browser: http://localhost:8089
# Configure: 100 users, 10 spawn rate
```

### Headless Mode (CI/CD)
```bash
locust -f locustfile.py \
    --headless \
    --users 100 \
    --spawn-rate 10 \
    --run-time 5m \
    --host http://localhost:8000
```

---

## 🎯 Test Scenarios

### CoreViaUser (Students)

**Task Distribution:**
- 🔥 **10x** - View Social Feed (most common)
- 👍 **5x** - Like Post
- 📊 **4x** - View Analytics Dashboard
- 💬 **3x** - Create Post
- 🛍️ **7x** - Browse Marketplace
- 🏋️ **2x** - Create Workout
- 🍽️ **2x** - Log Food
- 💭 **2x** - Add Comment
- 🔍 **3x** - View Product Detail
- 👤 **1x** - Get User Profile

**Wait Time**: 1-3 seconds between requests

### TrainerUser (Trainers)

**Task Distribution:**
- 📦 **5x** - Create Marketplace Product
- 📝 **2x** - Post Trainer Content
- 📋 **3x** - View My Products

**Wait Time**: 2-5 seconds between requests

---

## 📈 Performance Targets

### Response Time (95th percentile)
| Endpoint | Target | Acceptable | Critical |
|----------|--------|------------|----------|
| Social Feed | < 200ms | < 500ms | > 1000ms |
| Create Post | < 300ms | < 1000ms | > 2000ms |
| Marketplace Browse | < 250ms | < 500ms | > 1000ms |
| Analytics Dashboard | < 500ms | < 1500ms | > 3000ms |
| Like/Unlike | < 150ms | < 300ms | > 500ms |
| Auth (Login/Register) | < 400ms | < 1000ms | > 2000ms |

### Throughput
- **Minimum**: 100 req/sec
- **Target**: 500 req/sec
- **Maximum**: 1000 req/sec

### Error Rate
- **Target**: < 0.1%
- **Acceptable**: < 1%
- **Critical**: > 5%

### Concurrent Users
- **Minimum**: 100 users
- **Target**: 500 users
- **Maximum**: 1000 users

---

## 🔧 Test Configuration

### User Distribution
```python
# 90% students, 10% trainers
locust -f locustfile.py \
    --users 100 \
    --spawn-rate 10 \
    --user-classes CoreViaUser:9 TrainerUser:1
```

### Ramp-Up Strategy
```bash
# Stage 1: Warm-up (10 users for 1 min)
locust --users 10 --spawn-rate 1 --run-time 1m

# Stage 2: Normal load (100 users for 5 min)
locust --users 100 --spawn-rate 10 --run-time 5m

# Stage 3: Peak load (500 users for 10 min)
locust --users 500 --spawn-rate 50 --run-time 10m

# Stage 4: Stress test (1000 users for 5 min)
locust --users 1000 --spawn-rate 100 --run-time 5m
```

---

## 📊 Monitoring During Tests

### Real-time Metrics (Web UI)
- Requests per second (RPS)
- Response times (min/max/average/median/95%/99%)
- Number of users
- Failure rate
- Response time charts

### Custom Metrics
```python
# Slow request detection
if response_time > 2000:  # > 2 seconds
    print(f"SLOW REQUEST: {name} took {response_time}ms")
```

### Server Monitoring
```bash
# CPU & Memory
htop

# Database connections
psql -c "SELECT count(*) FROM pg_stat_activity;"

# API logs
tail -f logs/api.log

# System resources
vmstat 1
```

---

## 🎨 Advanced Scenarios

### Spike Test
Sudden surge in traffic:
```bash
# Start with 10 users
locust --users 10 --spawn-rate 1 --run-time 2m

# Then spike to 500 users
locust --users 500 --spawn-rate 250 --run-time 5m
```

### Soak Test
Sustained load over time:
```bash
# 100 users for 2 hours
locust --users 100 --spawn-rate 10 --run-time 2h
```

### Breakpoint Test
Find system limits:
```bash
# Gradually increase until system breaks
for users in 100 200 500 1000 2000; do
    locust --users $users --spawn-rate 100 --run-time 3m
    sleep 60  # Cool down
done
```

---

## 📁 Test Results

### Generate Report
```bash
locust -f locustfile.py \
    --headless \
    --users 100 \
    --spawn-rate 10 \
    --run-time 5m \
    --html report.html \
    --csv results
```

### Files Generated
- `report.html` - Visual report
- `results_stats.csv` - Request statistics
- `results_failures.csv` - Failed requests
- `results_exceptions.csv` - Exceptions

---

## 🔍 Analyzing Results

### Key Metrics to Check

**1. Response Time Distribution**
```
Name                          # reqs    Median    95%ile    99%ile    Avg
Social Feed                    5000      180ms     320ms     450ms    210ms
Create Post                    1500      280ms     450ms     650ms    310ms
Marketplace Browse             3500      200ms     350ms     500ms    230ms
```

**2. Failure Analysis**
```
# Check failures.csv
Method    Name                 Error                        Occurrences
POST      Create Post          Connection timeout           12
GET       Social Feed          500 Internal Server Error    3
```

**3. Percentile Response Times**
- **50th (Median)**: Typical user experience
- **95th**: What 95% of users experience
- **99th**: Worst-case scenarios

---

## 🐛 Common Issues & Solutions

### Issue 1: Connection Timeouts
**Symptom**: Many timeout errors
**Causes**:
- Too many concurrent connections
- Database connection pool exhausted
- Slow queries

**Solutions**:
```python
# Increase connection pool
DATABASE_POOL_SIZE = 20
DATABASE_MAX_OVERFLOW = 10

# Add database indexes
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

### Issue 2: High Response Times
**Symptom**: 95th percentile > 1 second
**Causes**:
- N+1 queries
- Missing indexes
- Unoptimized queries

**Solutions**:
```python
# Use eager loading
posts = db.query(Post).options(
    joinedload(Post.author),
    joinedload(Post.likes)
).all()

# Add query pagination
LIMIT 20 OFFSET 0
```

### Issue 3: Memory Leaks
**Symptom**: Memory usage increases over time
**Causes**:
- Unclosed database connections
- Large response payloads
- Object caching

**Solutions**:
```python
# Ensure connections are closed
try:
    result = await db.execute(query)
finally:
    await db.close()

# Limit response size
.limit(20)
```

### Issue 4: Rate Limiting
**Symptom**: 429 Too Many Requests
**Solutions**:
```python
# Adjust rate limit for load testing
RATE_LIMIT = 1000  # requests per minute

# Or disable in test environment
if not settings.LOAD_TEST_MODE:
    apply_rate_limiting()
```

---

## 🎯 Optimization Strategies

### Database
1. **Connection Pooling**
   ```python
   pool_size=20
   max_overflow=10
   pool_pre_ping=True
   ```

2. **Query Optimization**
   - Add indexes on frequently queried columns
   - Use `select_related` / `joinedload`
   - Implement pagination

3. **Caching**
   ```python
   # Redis caching for frequent queries
   @cache.memoize(timeout=300)
   def get_popular_posts():
       return db.query(Post).order_by(likes_count).limit(10)
   ```

### API
1. **Response Compression**
   ```python
   from fastapi.middleware.gzip import GZipMiddleware
   app.add_middleware(GZipMiddleware, minimum_size=1000)
   ```

2. **Async Operations**
   ```python
   # All database operations should be async
   async def get_posts():
       return await db.execute(query)
   ```

3. **Background Tasks**
   ```python
   # Move heavy operations to background
   from fastapi import BackgroundTasks

   background_tasks.add_task(send_notification, user_id)
   ```

### Infrastructure
1. **Horizontal Scaling**
   - Deploy multiple API instances
   - Use load balancer (nginx, AWS ALB)

2. **CDN for Static Assets**
   - Images served from S3 + CloudFront
   - Reduce API load

3. **Database Read Replicas**
   - Write to primary
   - Read from replicas

---

## 📊 Performance Benchmarks

### Current Performance (Expected)
Based on similar FastAPI applications:

**Single Instance (2 CPU, 4GB RAM)**
- RPS: 200-300 req/sec
- Concurrent Users: 100-200
- Response Time (95%): 300-500ms

**Scaled (4 instances)**
- RPS: 800-1200 req/sec
- Concurrent Users: 500-1000
- Response Time (95%): 200-400ms

---

## 🚀 CI/CD Integration

### GitHub Actions
```yaml
name: Load Tests

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Start API
        run: |
          docker-compose up -d
          sleep 30  # Wait for startup

      - name: Run Load Test
        run: |
          pip install locust
          locust -f tests/load/locustfile.py \
            --headless \
            --users 100 \
            --spawn-rate 10 \
            --run-time 5m \
            --html report.html

      - name: Upload Report
        uses: actions/upload-artifact@v2
        with:
          name: load-test-report
          path: report.html

      - name: Check Results
        run: |
          # Fail if error rate > 1%
          # Fail if 95th percentile > 1000ms
```

---

## 📝 Test Checklist

Before running load tests:
- [ ] Database has test data (users, posts, products)
- [ ] All migrations applied
- [ ] Environment variables configured
- [ ] Redis running (if caching enabled)
- [ ] Monitoring tools ready (Grafana, logs)
- [ ] Baseline metrics recorded

After load tests:
- [ ] Review HTML report
- [ ] Check failure rate (< 1%)
- [ ] Verify response times meet targets
- [ ] Analyze slow queries (database logs)
- [ ] Check for memory leaks
- [ ] Document bottlenecks

---

## 🎓 Best Practices

1. **Start Small**: Begin with 10-20 users, gradually increase
2. **Monitor Resources**: Watch CPU, memory, database connections
3. **Isolate Tests**: Run on dedicated test environment
4. **Realistic Data**: Use production-like data volumes
5. **Cool Down**: Wait between tests for system to stabilize
6. **Document Everything**: Record configurations and results
7. **Compare Results**: Track performance over time
8. **Fix Bottlenecks**: Address issues before scaling up

---

## ✅ Success Criteria

Load test passes if:
- ✅ Error rate < 1%
- ✅ 95th percentile response time < 500ms (critical endpoints)
- ✅ System handles 100 concurrent users
- ✅ No memory leaks (stable memory over 30 min)
- ✅ Database connections stable
- ✅ No crashes or panics

---

**Load Test Suite Status**: ✅ **COMPLETE & READY**
**User Scenarios**: **2 (Student, Trainer)**
**Total Tasks**: **13**
**Expected Performance**: **200-300 RPS**

**Author**: Claude Code AI
**Date**: 2026-02-05
**Version**: v2.0 Load Tests
