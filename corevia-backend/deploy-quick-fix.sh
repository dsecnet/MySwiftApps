#!/bin/bash

echo "🚀 Deploying Quick Fixes to Hetzner..."

# Backend server IP
SERVER="root@95.217.244.107"
APP_DIR="/var/www/corevia"

# Copy updated auth.py
echo "📤 Uploading updated auth.py..."
scp app/routers/auth.py $SERVER:$APP_DIR/app/routers/auth.py

# Restart services
echo "🔄 Restarting backend services..."
ssh $SERVER << 'ENDSSH'
cd /var/www/corevia
supervisorctl restart corevia
echo "✅ Services restarted"
ENDSSH

echo ""
echo "✅ Deployment Complete!"
echo "🌐 Backend: https://api.corevia.life"
echo "📋 Check logs: ssh root@95.217.244.107 'tail -f /var/log/supervisor/corevia.log'"
