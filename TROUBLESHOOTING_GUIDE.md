# Troubleshooting & Optimization Guide

## 🔧 Common Issues & Solutions

### Docker & Container Issues

#### Issue: Containers not starting
```bash
# Check Docker status
docker ps -a
docker compose ps

# View logs for specific service
docker compose logs frontend
docker compose logs backend
docker compose logs mysql

# Common solutions
docker compose down -v  # Remove volumes if corrupted
docker compose up -d --build  # Rebuild containers
docker system prune -a  # Clean up Docker system
```

#### Issue: Port conflicts
```bash
# Check what's using the ports
netstat -tulpn | grep :8200
netstat -tulpn | grep :8201
netstat -tulpn | grep :8203

# Kill processes using the ports
sudo kill -9 $(lsof -t -i:8200)

# Or modify docker-compose.yml to use different ports
```

#### Issue: Permission errors in containers
```bash
# Fix Laravel permissions
./laravel-setup.sh

# Or manually fix permissions
docker compose exec php_fpm chown -R www-data:www-data /var/www/storage
docker compose exec php_fpm chmod -R 775 /var/www/storage
```

### Database Issues

#### Issue: MySQL connection refused
```bash
# Check MySQL container status
docker compose logs mysql

# Connect to MySQL directly
docker compose exec mysql mysql -u root -p

# Reset MySQL if corrupted
docker compose down
docker volume rm vibecode-full-stack-starter-kit_mysql_data
docker compose up -d mysql
```

#### Issue: Database migrations failing
```bash
# Run migrations manually
docker compose exec php_fpm php artisan migrate

# Reset and re-run migrations
docker compose exec php_fpm php artisan migrate:fresh --seed

# Check migration status
docker compose exec php_fpm php artisan migrate:status
```

#### Issue: Slow database queries
```sql
-- Enable MySQL slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;

-- Check for missing indexes
SHOW INDEX FROM ai_tools;
SHOW INDEX FROM tool_ratings;

-- Analyze query performance
EXPLAIN SELECT * FROM ai_tools WHERE status = 'approved';
```

### Frontend Issues

#### Issue: Next.js build failures
```bash
# Clear Next.js cache
cd frontend
rm -rf .next
npm run build

# Check for TypeScript errors
npm run type-check

# Update dependencies
npm update
```

#### Issue: API connection errors
```javascript
// Check API base URL configuration
console.log(process.env.NEXT_PUBLIC_API_URL);

// Test API connectivity
curl http://localhost:8201/api/ai-tools

// Check CORS configuration in Laravel
// backend/config/cors.php
```

#### Issue: Authentication not working
```bash
# Check Laravel Sanctum configuration
docker compose exec php_fpm php artisan config:cache

# Verify session configuration
# Check backend/.env for SESSION_DRIVER=redis

# Test authentication endpoint
curl -X POST http://localhost:8201/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Performance Issues

#### Issue: Slow API responses
```php
// Enable Laravel query logging
// In AppServiceProvider.php
DB::listen(function ($query) {
    Log::info($query->sql, $query->bindings, $query->time);
});

// Check for N+1 queries
// Use Laravel Debugbar or Telescope
composer require barryvdh/laravel-debugbar --dev
```

#### Issue: High memory usage
```bash
# Monitor container resource usage
docker stats

# Check PHP memory limit
docker compose exec php_fpm php -i | grep memory_limit

# Optimize PHP-FPM configuration
# Edit docker/php.ini
memory_limit = 256M
max_execution_time = 60
```

#### Issue: Slow frontend loading
```bash
# Analyze bundle size
cd frontend
npm run build
npx @next/bundle-analyzer

# Optimize images
# Use next/image component
# Implement lazy loading
```

## 🚀 Performance Optimizations

### Database Optimizations

#### Add Database Indexes
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_ai_tools_status ON ai_tools(status);
CREATE INDEX idx_ai_tools_created_at ON ai_tools(created_at);
CREATE INDEX idx_tool_ratings_ai_tool_id ON tool_ratings(ai_tool_id);
CREATE INDEX idx_tool_ratings_rating ON tool_ratings(rating);
CREATE INDEX idx_tool_ratings_created_at ON tool_ratings(created_at);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

#### Optimize Laravel Queries
```php
// Use eager loading to prevent N+1 queries
$tools = AITool::with(['categories', 'ratings.user', 'submitter'])
    ->approved()
    ->paginate(20);

// Use select to limit columns
$tools = AITool::select(['id', 'name', 'description', 'url'])
    ->approved()
    ->get();

// Use database-level aggregations
$stats = AITool::selectRaw('
    COUNT(*) as total,
    SUM(CASE WHEN status = "approved" THEN 1 ELSE 0 END) as approved,
    SUM(CASE WHEN status = "pending" THEN 1 ELSE 0 END) as pending
')->first();
```

#### Implement Query Caching
```php
// Cache expensive queries
$popularTools = Cache::remember('popular_tools', 3600, function () {
    return AITool::with('ratings')
        ->approved()
        ->orderByDesc('average_rating')
        ->limit(10)
        ->get();
});

// Cache user-specific data
$userTools = Cache::remember("user_{$userId}_tools", 1800, function () use ($userId) {
    return AITool::where('submitted_by', $userId)->get();
});
```

### Redis Optimizations

#### Configure Redis for Performance
```bash
# Edit redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000

# Monitor Redis performance
docker compose exec redis redis-cli info memory
docker compose exec redis redis-cli info stats
```

#### Implement Smart Caching
```php
// Cache rating statistics
Cache::remember("tool_{$toolId}_stats", 3600, function () use ($toolId) {
    return [
        'average_rating' => ToolRating::averageRatingForTool($toolId),
        'total_ratings' => ToolRating::countForTool($toolId),
        'distribution' => ToolRating::distributionForTool($toolId),
    ];
});

// Cache category data
Cache::remember('categories_with_counts', 7200, function () {
    return Category::withCount('tools')->get();
});
```

### Frontend Optimizations

#### Implement Code Splitting
```typescript
// Use dynamic imports for large components
const AdminPanel = dynamic(() => import('@/components/AdminPanel'), {
  loading: () => <div>Loading admin panel...</div>,
});

// Split by routes
const Dashboard = dynamic(() => import('@/components/Dashboard'));
const ToolsList = dynamic(() => import('@/components/ToolsList'));
```

#### Optimize API Calls
```typescript
// Implement request deduplication
const cache = new Map();

export async function getAITools(): Promise<AITool[]> {
  const cacheKey = 'ai-tools';
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }
  
  const tools = await fetch(`${API_BASE_URL}/ai-tools`).then(r => r.json());
  cache.set(cacheKey, tools);
  
  // Clear cache after 5 minutes
  setTimeout(() => cache.delete(cacheKey), 300000);
  
  return tools;
}

// Use React Query for better caching
import { useQuery } from '@tanstack/react-query';

function useAITools() {
  return useQuery({
    queryKey: ['ai-tools'],
    queryFn: getAITools,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}
```

#### Implement Virtual Scrolling
```typescript
// For large lists of tools
import { FixedSizeList as List } from 'react-window';

const ToolsList = ({ tools }: { tools: AITool[] }) => {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <ToolCard tool={tools[index]} />
    </div>
  );

  return (
    <List
      height={600}
      itemCount={tools.length}
      itemSize={120}
      width="100%"
    >
      {Row}
    </List>
  );
};
```

### Infrastructure Optimizations

#### Nginx Configuration
```nginx
# nginx/laravel.conf
server {
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Enable caching for static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
```

#### Docker Optimizations
```dockerfile
# Optimize PHP-FPM configuration
# docker/Dockerfile.php
RUN echo "pm = dynamic" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.max_children = 20" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.start_servers = 2" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.min_spare_servers = 1" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.max_spare_servers = 3" >> /usr/local/etc/php-fpm.d/www.conf

# Optimize MySQL configuration
# Add to docker-compose.yml mysql service
command: --innodb-buffer-pool-size=256M --max-connections=100
```

## 🔍 Monitoring & Debugging

### Laravel Debugging

#### Enable Debug Mode
```bash
# In backend/.env
APP_DEBUG=true
LOG_LEVEL=debug

# View logs
docker compose logs php_fpm -f
tail -f backend/storage/logs/laravel.log
```

#### Use Laravel Telescope
```bash
# Install Telescope for development
docker compose exec php_fpm composer require laravel/telescope --dev
docker compose exec php_fpm php artisan telescope:install
docker compose exec php_fpm php artisan migrate

# Access at http://localhost:8201/telescope
```

### Frontend Debugging

#### React Developer Tools
```bash
# Install React DevTools browser extension
# Enable React strict mode in development

# Add debugging to components
console.log('Component props:', props);
console.log('Component state:', state);
```

#### Performance Profiling
```typescript
// Use React Profiler
import { Profiler } from 'react';

function onRenderCallback(id: string, phase: string, actualDuration: number) {
  console.log('Component render:', { id, phase, actualDuration });
}

<Profiler id="ToolsList" onRender={onRenderCallback}>
  <ToolsList />
</Profiler>
```

### Database Monitoring

#### Query Performance
```sql
-- Enable performance schema
SET GLOBAL performance_schema = ON;

-- Monitor slow queries
SELECT * FROM performance_schema.events_statements_summary_by_digest 
WHERE avg_timer_wait > 1000000000 
ORDER BY avg_timer_wait DESC;

-- Check table sizes
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'vibecode-full-stack-starter-kit_app'
ORDER BY (data_length + index_length) DESC;
```

## 🛡️ Security Hardening

### Laravel Security

#### Environment Security
```bash
# Secure .env file permissions
chmod 600 backend/.env

# Use strong APP_KEY
docker compose exec php_fpm php artisan key:generate

# Configure secure session settings
# In backend/.env
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=strict
```

#### Input Validation
```php
// Always validate input
$request->validate([
    'name' => 'required|string|max:255|regex:/^[a-zA-Z0-9\s\-_]+$/',
    'email' => 'required|email|max:255',
    'rating' => 'required|integer|between:1,5',
    'comment' => 'nullable|string|max:1000',
]);

// Sanitize output
echo e($userInput); // Escape HTML
echo strip_tags($userInput); // Remove HTML tags
```

### Database Security

#### Secure MySQL Configuration
```sql
-- Remove test databases and users
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;

-- Use strong passwords
ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_random_password';
```

### Infrastructure Security

#### Docker Security
```yaml
# docker-compose.yml security settings
services:
  php_fpm:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/tmp
```

#### Network Security
```bash
# Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 8203/tcp  # Block direct MySQL access
sudo ufw enable
```

This guide provides comprehensive troubleshooting steps and optimization strategies to maintain a high-performance, secure AI Tools Management Platform.