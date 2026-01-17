#!/bin/bash

echo "🚀 Setting up AI Tools Hub..."

# Run migrations
echo "📦 Running database migrations..."
docker compose exec php_fpm php artisan migrate --force

echo "✅ Setup complete!"
echo ""
echo "Access the platform at: http://localhost:8200"
echo "API endpoint: http://localhost:8201/api/ai-tools"
