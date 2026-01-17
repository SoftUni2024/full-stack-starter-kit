# Full Stack Starter Kit - Complete Documentation

A comprehensive full-stack application with AI tool management, 2FA authentication, admin panel, and audit logging built with Laravel and Next.js.

## Table of Contents

- [Installation Instructions](#installation-instructions)
- [Docker Setup](#docker-setup)
- [How to Add Bots/Tools](#how-to-add-botstools)
- [Role System & Permissions](#role-system--permissions)
- [AI Agents & Development](#ai-agents--development)
- [API Documentation](#api-documentation)
- [Project Architecture](#project-architecture)
- [Troubleshooting](#troubleshooting)

---

## Installation Instructions

### Prerequisites

- Docker & Docker Compose (recommended)
- Or manually: PHP 8.2+, Node.js 18+, MySQL 8.0+, Redis 7+
- Git

### Quick Start (With Docker)

```bash
# Clone the repository
git clone <repo-url>
cd full-stack-starter-kit

# Copy environment file
cp backend/env.template backend/.env

# Start all services
docker compose up -d

# Install dependencies
docker compose exec app composer install
docker compose exec app npm install

# Generate app key
docker compose exec app php artisan key:generate

# Run migrations and seed
docker compose exec app php artisan migrate:fresh --seed

# Build frontend
cd frontend
npm run build
npm run dev

# Access the application
Frontend: http://localhost:3000
Backend API: http://localhost:8201/api
```

### Manual Installation

**Backend Setup:**
```bash
cd backend
composer install
cp env.template .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

**Frontend Setup:**
```bash
cd frontend
npm install
npm run dev
```

**Services Required:**
- MySQL: `localhost:3306`
- Redis: `localhost:6379`

### Environment Configuration

**Backend (.env):**
```env
APP_NAME="AI Tools Manager"
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost:8201

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=vibe_code
DB_USERNAME=root
DB_PASSWORD=root

CACHE_DRIVER=redis
REDIS_HOST=redis
REDIS_PORT=6379

MAIL_FROM_ADDRESS=noreply@example.com
GOOGLE2FA_ENABLED=true
```

**Frontend (.env.local):**
```env
NEXT_PUBLIC_API_URL=http://localhost:8201/api
```

---

## Docker Setup

### Available Services

```yaml
- **app** (PHP): Laravel application server
- **nginx**: Web server & reverse proxy
- **mysql**: Database server (port 3306)
- **redis**: Cache & session store (port 6379)
- **mailhog**: Email testing (port 1025, UI: 8025)
```

### Docker Commands

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f app

# Stop services
docker compose down

# Fresh database
docker compose exec app php artisan migrate:fresh --seed

# Run artisan commands
docker compose exec app php artisan <command>

# Run npm commands
docker compose exec app npm <command>

# Access MySQL directly
docker compose exec mysql mysql -u root -proot vibe_code

# Access Redis CLI
docker compose exec redis redis-cli
```

### Docker Architecture

```
┌─────────────┐
│   Nginx     │ (Port 8201)
└──────┬──────┘
       │
┌──────▼──────┐     ┌─────────┐
│ Laravel App │────▶│ MySQL   │ (Port 3306)
└──────┬──────┘     └─────────┘
       │            ┌────────────┐
       └───────────▶│ Redis      │ (Port 6379)
                    └────────────┘
```

---

## How to Add Bots/Tools

### 1. Via Admin Panel (Recommended)

**For Admin Users (Owner Role):**

1. Login with owner account
2. Navigate to "Manage Tools" → "Add New Tool"
3. Fill in tool details:
   - **Name**: Tool identifier
   - **Description**: What the tool does
   - **Category**: Select or create category
   - **Endpoint**: API/Integration URL
   - **Authentication**: API key or OAuth settings
   - **Documentation**: Usage guidelines

4. Submit for approval (auto-approved for owners)
5. Tool appears in public list immediately

### 2. Via API

```bash
# Create a new tool
curl -X POST http://localhost:8201/api/tools \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Custom Bot",
    "description": "Does something awesome",
    "category_id": 1,
    "endpoint": "https://api.example.com/bot",
    "documentation": "Full usage guide here"
  }'
```

**Response:**
```json
{
  "id": 10,
  "name": "Custom Bot",
  "status": "pending",
  "submitted_by": "user_id",
  "created_at": "2026-01-17T10:00:00Z"
}
```

### 3. Tool Approval Workflow

**Pending Tools:**
- Users submit tools → Status: `pending`
- Admins review in Admin Panel → Tools tab
- Admin can **Approve** (visible to all) or **Reject** (with reason)
- Action logged in Audit Trail

**Tool Lifecycle:**
```
User Submits → Pending → Admin Reviews → Approved/Rejected → Visible/Hidden
```

### 4. Tool Metadata

Each tool stores:
- `name`, `description`, `endpoint`, `documentation`
- `status`: pending|approved|rejected
- `categories`: Many-to-many relationship
- `submitted_by`: User ID who created it
- `approved_by`: User ID who approved it
- `rejection_reason`: Why it was rejected (if rejected)

---

## Role System & Permissions

### Available Roles

| Role | Permissions | Access Level |
|------|------------|--------------|
| **owner** | Full system access, admin panel, approve/reject tools | All features |
| **moderator** | Approve/reject tools, view audit logs | Admin panel (limited) |
| **user** | Submit tools, use approved tools, 2FA setup | Basic features |
| **guest** | Browse public tools only | Read-only |

### Permission Matrix

| Feature | Owner | Moderator | User | Guest |
|---------|-------|-----------|------|-------|
| View public tools | ✅ | ✅ | ✅ | ✅ |
| Submit new tools | ✅ | ✅ | ✅ | ❌ |
| Admin panel | ✅ | ✅ | ❌ | ❌ |
| Approve/Reject tools | ✅ | ✅ | ❌ | ❌ |
| View audit logs | ✅ | ✅ | ❌ | ❌ |
| Manage users | ✅ | ❌ | ❌ | ❌ |
| Setup 2FA | ✅ | ✅ | ✅ | ❌ |

### Implementing Role-Based Access

**Backend (CheckRole Middleware):**
```php
// In routes/api.php
Route::middleware(['auth:sanctum', 'role:owner'])->group(function () {
    Route::post('/admin/tools/{id}/approve', [AdminController::class, 'approveTool']);
    Route::post('/admin/tools/{id}/reject', [AdminController::class, 'rejectTool']);
});
```

**Frontend (ProtectedRoute Component):**
```tsx
<ProtectedRoute user={user} requiredRole="owner">
  <AdminPanel />
</ProtectedRoute>
```

### Assigning Roles to Users

```bash
# Via Artisan command
docker compose exec app php artisan tinker

# In tinker shell
$user = User::find(1);
$user->role = 'moderator';
$user->save();
```

---

## AI Agents & Development

### Overview

This project integrates with GitHub Copilot and custom AI development agents for:
- Code generation & migration
- Feature implementation
- Bug fixes & optimization
- Documentation generation

### Development Agent Prompt

Use this prompt when starting a new development session:

```markdown
You are working on a Full Stack AI Tools Manager application built with:
- Backend: Laravel 12.23.1, PHP 8.2, MySQL 8.0, Redis 7, Sanctum Auth
- Frontend: Next.js 15.4.6, React 19, TypeScript 5, Tailwind CSS 4

### Current Features Implemented:
1. **Authentication**: Email/Password + 2FA (Email, Telegram, Google Authenticator)
2. **AI Tool Management**: CRUD operations with approval workflow
3. **Admin Panel**: Dashboard, tool approval queue, audit logging
4. **Middleware**: Role-based access control (owner, moderator, user)
5. **Caching**: Redis caching for categories and tools (1-hour TTL)
6. **Audit Logging**: Complete action tracking with IP/User Agent

### Project Structure:
```
backend/
  ├── app/Models/
  │   ├── User.php
  │   ├── AITool.php
  │   ├── Category.php
  │   ├── TwoFASetting.php
  │   └── AuditLog.php
  ├── app/Http/Controllers/
  │   ├── AuthController.php
  │   ├── AIToolController.php
  │   ├── TwoFAController.php
  │   └── AdminController.php
  ├── app/Http/Middleware/
  │   ├── CheckRole.php
  │   └── Check2FA.php
  └── routes/api.php

frontend/
  ├── src/components/
  │   ├── AdminPanel.tsx
  │   ├── AdminDashboard.tsx
  │   ├── AdminToolList.tsx
  │   ├── AdminAuditLog.tsx
  │   ├── TwoFASetupModal.tsx
  │   ├── TwoFAVerifyModal.tsx
  │   ├── TwoFAStatus.tsx
  │   └── ProtectedRoute.tsx
  ├── src/lib/api.ts
  ├── src/types/admin.ts
  └── src/app/page.tsx
```

### When Implementing Features:

1. **Backend**: Add model, migration, controller, route
2. **Test**: Use `php artisan tinker` or curl for API testing
3. **Frontend**: Create component, add API function, integrate
4. **TypeScript**: Always use strict types (no `any`)
5. **Caching**: Use Redis for frequently accessed data
6. **Logging**: Use AuditLog model for all user actions
7. **Middleware**: Protect routes with CheckRole/Check2FA

### Common Tasks:

**Add New Tool**:
- Create model: `php artisan make:model NewTool -m`
- Create controller: `php artisan make:controller NewController`
- Add routes: `routes/api.php`
- Create component: `frontend/src/components/NewComponent.tsx`

**Add Permission**:
- Update `CheckRole` middleware
- Add route group in `routes/api.php`
- Add frontend guard with `ProtectedRoute`

**Add Audit Log Entry**:
```php
AuditLog::log($user->id, 'action_name', 'ModelName', $id, $oldData, $newData);
```

**Cache Data**:
```php
Cache::remember('key', 3600, fn() => Model::get());
```

### Testing Commands:

```bash
# Test 2FA setup
curl -X POST http://localhost:8201/api/auth/2fa/setup \
  -H "Authorization: Bearer TOKEN" \
  -d '{"method":"email"}'

# Test tool approval
curl -X POST http://localhost:8201/api/admin/tools/1/approve \
  -H "Authorization: Bearer TOKEN"

# View audit logs
curl http://localhost:8201/api/admin/audit-logs \
  -H "Authorization: Bearer TOKEN"

# Check cache
docker compose exec redis redis-cli
> KEYS *
> GET key_name
```

### Performance Optimization:

- Categories cached 1 hour
- Approved tools cached 1 hour  
- Pending tools cached 5 minutes (short TTL for real-time updates)
- Use database indexing for frequently queried columns
- Implement pagination for large datasets (50 items per page)

### When Debugging:

1. Check Laravel logs: `docker compose logs -f app`
2. Check frontend console: Browser DevTools
3. Database query: `php artisan tinker` → `DB::enableQueryLog()`
4. Cache issues: `docker compose exec redis redis-cli FLUSHALL`

### Security Best Practices:

1. Always validate input with Laravel validators
2. Use Sanctum tokens (15-minute expiry recommended)
3. Hash sensitive data in audit logs
4. Check roles before actions
5. Log all admin actions
6. Implement rate limiting for APIs
7. CORS enabled only for frontend origin
```

### Feature Request Template

When asked to implement a feature, provide:

```markdown
## Feature: [Feature Name]

### Requirements:
- What should it do?
- Which roles need access?
- Should it be cached?
- What data needs logging?

### API Endpoints:
- POST /api/feature/create
- GET /api/feature/list
- etc.

### Database Changes:
- New table or columns?

### Frontend Components:
- Which new components needed?

### Testing:
- curl commands to test
```

---

## API Documentation

### Authentication

**Login:**
```bash
POST /api/auth/login
{
  "email": "owner@example.com",
  "password": "password"
}
```

**Response:**
```json
{
  "token": "bearer_token_here",
  "user": {
    "id": 1,
    "name": "Owner User",
    "email": "owner@example.com",
    "role": "owner"
  }
}
```

**Logout:**
```bash
POST /api/auth/logout
Authorization: Bearer {token}
```

### AI Tools

**List Tools:**
```bash
GET /api/tools
GET /api/tools?status=approved&category_id=1
```

**Create Tool:**
```bash
POST /api/tools
Authorization: Bearer {token}
{
  "name": "Bot Name",
  "description": "Description",
  "category_id": 1,
  "endpoint": "https://api.url"
}
```

**Update Tool:**
```bash
PUT /api/tools/{id}
Authorization: Bearer {token}
```

**Delete Tool:**
```bash
DELETE /api/tools/{id}
Authorization: Bearer {token}
```

### Admin Operations

**Get Stats:**
```bash
GET /api/admin/stats
Authorization: Bearer {token}
```

**Get Pending Tools:**
```bash
GET /api/admin/tools?status=pending
Authorization: Bearer {token}
```

**Approve Tool:**
```bash
POST /api/admin/tools/{id}/approve
Authorization: Bearer {token}
```

**Reject Tool:**
```bash
POST /api/admin/tools/{id}/reject
Authorization: Bearer {token}
{
  "rejection_reason": "Reason here"
}
```

**Audit Logs:**
```bash
GET /api/admin/audit-logs
GET /api/admin/audit-logs?action=created_tool&from_date=2026-01-01
Authorization: Bearer {token}
```

### 2FA Operations

**Setup 2FA:**
```bash
POST /api/auth/2fa/setup
Authorization: Bearer {token}
{
  "method": "email|telegram|google_authenticator",
  "telegram_chat_id": "123456789" // only for telegram
}
```

**Verify 2FA:**
```bash
POST /api/auth/2fa/verify
Authorization: Bearer {token}
{
  "method": "email",
  "code": "123456"
}
```

**List 2FA Methods:**
```bash
GET /api/auth/2fa/list
Authorization: Bearer {token}
```

**Disable 2FA:**
```bash
POST /api/auth/2fa/disable
Authorization: Bearer {token}
{
  "method": "email"
}
```

---

## Project Architecture

### Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Next.js | 15.4.6 |
| UI Library | React | 19.1.0 |
| Styling | Tailwind CSS | 4.x |
| Language | TypeScript | 5.x |
| Backend | Laravel | 12.23.1 |
| Runtime | PHP | 8.2 |
| Database | MySQL | 8.0 |
| Cache | Redis | 7.x |
| Auth | Sanctum | Latest |
| 2FA | PragmaRX/Google2FA | Latest |

### Database Schema

```sql
-- Users
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  role ENUM('owner', 'moderator', 'user', 'guest'),
  created_at TIMESTAMP
);

-- AI Tools
CREATE TABLE ai_tools (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  description TEXT,
  endpoint VARCHAR(255),
  documentation TEXT,
  status ENUM('pending', 'approved', 'rejected'),
  submitted_by BIGINT REFERENCES users(id),
  approved_by BIGINT REFERENCES users(id),
  rejection_reason TEXT,
  created_at TIMESTAMP
);

-- Categories
CREATE TABLE categories (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  slug VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP
);

-- Tool-Category Many-to-Many
CREATE TABLE ai_tool_category (
  id BIGINT PRIMARY KEY,
  ai_tool_id BIGINT REFERENCES ai_tools(id),
  category_id BIGINT REFERENCES categories(id),
  created_at TIMESTAMP
);

-- 2FA Settings
CREATE TABLE two_fa_settings (
  id BIGINT PRIMARY KEY,
  user_id BIGINT REFERENCES users(id),
  method ENUM('email', 'telegram', 'google_authenticator'),
  is_enabled BOOLEAN,
  is_verified BOOLEAN,
  secret VARCHAR(255),
  telegram_chat_id VARCHAR(255),
  backup_codes JSON,
  created_at TIMESTAMP
);

-- Audit Logs
CREATE TABLE audit_logs (
  id BIGINT PRIMARY KEY,
  user_id BIGINT REFERENCES users(id),
  action VARCHAR(255),
  entity_type VARCHAR(255),
  entity_id BIGINT,
  old_values JSON,
  new_values JSON,
  ip_address VARCHAR(255),
  user_agent TEXT,
  status VARCHAR(50),
  description TEXT,
  created_at TIMESTAMP
);
```

### Request Flow

```
Browser
   │
   ├─────► Frontend (Next.js)
   │         ├─ Auth (Sanctum token)
   │         ├─ 2FA verification
   │         └─ Role checking
   │
   └─────► Backend API (Laravel)
             ├─ Sanctum Auth middleware
             ├─ Check2FA middleware
             ├─ CheckRole middleware
             ├─ Business logic
             ├─ Audit logging
             └─ Cache layer (Redis)
                 │
                 └─ Database (MySQL)
```

### Caching Strategy

```
Redis Cache Keys:
- categories         → 3600s (1 hour)
- approved_tools     → 3600s (1 hour)
- pending_tools      → 300s  (5 minutes)
- user_{id}_2fa      → 60s   (1 minute)
- stats_{month}      → 1800s (30 minutes)
```

---

## Troubleshooting

### Common Issues & Solutions

**Database Connection Failed**
```bash
# Check MySQL is running
docker compose logs mysql

# Verify credentials in .env
docker compose exec app php artisan tinker
> DB::connection()->getPdo()

# Reset database
docker compose exec app php artisan migrate:fresh --seed
```

**2FA QR Code Not Displaying**
```bash
# QR codes generated via API
# Check response includes qr_code field
curl http://localhost:8201/api/auth/2fa/setup \
  -H "Authorization: Bearer TOKEN" \
  -d '{"method":"google_authenticator"}' \
  | jq '.qr_code'
```

**Tools Not Appearing in Admin Panel**
```bash
# Check database
docker compose exec app php artisan tinker
> DB::table('ai_tools')->get()

# Verify Redis cache
docker compose exec redis redis-cli
> KEYS *
> DEL approved_tools  # Clear cache
```

**Build Errors on Frontend**
```bash
# Clear node modules and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Audit Logs Not Recording**
```bash
# Check middleware is applied
grep -r "AuditLog::log" backend/app

# Verify user is authenticated
docker compose logs -f app | grep "AuditLog"
```

**Redis Connection Issues**
```bash
# Test Redis connection
docker compose exec app php artisan tinker
> Cache::put('test', 'value')
> Cache::get('test')

# Restart Redis
docker compose restart redis
```

### Performance Tuning

**Database Optimization:**
```sql
-- Add indexes
ALTER TABLE ai_tools ADD INDEX idx_status (status);
ALTER TABLE ai_tools ADD INDEX idx_submitted_by (submitted_by);
ALTER TABLE audit_logs ADD INDEX idx_user_id (user_id);
ALTER TABLE audit_logs ADD INDEX idx_created_at (created_at);
```

**Redis Optimization:**
```bash
# Monitor cache hits
docker compose exec redis redis-cli INFO stats

# Optimize memory
docker compose exec redis redis-cli INFO memory
```

**Frontend Optimization:**
```bash
# Build optimization
npm run build
npm run analyze

# Check bundle size
npm run build -- --analyze
```

---

## Contributing

### Development Workflow

1. Create feature branch: `git checkout -b feature/feature-name`
2. Make changes and test locally
3. Run tests: `npm test` (frontend), `php artisan test` (backend)
4. Create pull request with description
5. Code review & merge

### Code Standards

- **Backend**: PSR-12 coding standard
- **Frontend**: ESLint + Prettier configuration
- **Tests**: Unit & feature tests required
- **Documentation**: Update README for new features

---

## Support & Debugging

For issues:
1. Check logs: `docker compose logs -f app`
2. Check database: `docker compose exec mysql mysql -u root -proot vibe_code`
3. Check Redis: `docker compose exec redis redis-cli`
4. Review audit logs in admin panel

---

## License

This project is open source and available under the MIT License.

---

**Last Updated**: January 17, 2026  
**Version**: 1.0.0
