# AI Tools Management Platform

A comprehensive full-stack platform for managing AI tools with role-based access, ratings, comments, and administrative features.

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git
- Node.js 18+ (for local development)
- PHP 8.2+ (for local development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd full-stack-starter-kit
   ```

2. **Start with Docker (Recommended):**
   ```bash
   ./start.sh
   ```

3. **Access the application:**
   - Frontend: http://localhost:8200
   - Backend API: http://localhost:8201
   - Database: localhost:8203 (MySQL)
   - Redis: localhost:8204

## 🐳 Docker Setup

### Services Overview
- **frontend**: Next.js React application (Port 8200)
- **backend**: Nginx reverse proxy (Port 8201)
- **php_fpm**: Laravel PHP-FPM backend
- **mysql**: MySQL 8.0 database (Port 8203)
- **redis**: Redis cache server (Port 8204)
- **tools**: Development utilities container (Port 8205)

### Docker Commands

```bash
# Start all services
./start.sh

# Stop all services
./stop.sh

# View service status
docker compose ps

# View logs
docker compose logs -f [service_name]

# Restart specific service
docker compose restart frontend
docker compose restart backend

# Access container shell
docker compose exec frontend sh
docker compose exec php_fpm sh

# Database operations
./db-manage.sh connect    # Connect to MySQL
./db-manage.sh backup     # Create backup
./db-manage.sh redis      # Connect to Redis
```

### Environment Configuration

**Database Credentials:**
- Host: mysql (internal) / localhost:8203 (external)
- Database: vibecode-full-stack-starter-kit_app
- Username: root
- Password: vibecode-full-stack-starter-kit_mysql_pass

**Redis Configuration:**
- Host: redis (internal) / localhost:8204 (external)
- Password: vibecode-full-stack-starter-kit_redis_pass

## 🤖 AI Agents & Bots

### Adding AI Tools/Bots

The platform supports managing various AI tools and bots through a comprehensive interface:

#### 1. Via Web Interface
1. Navigate to http://localhost:8200
2. Login with your credentials
3. Click "Add Tool" button
4. Fill out the 3-step wizard:
   - **Step 1**: Basic Information (name, description, URL)
   - **Step 2**: Categories and Tags
   - **Step 3**: Role Assignments

#### 2. Via API
```bash
# Create a new AI tool
curl -X POST http://localhost:8201/api/ai-tools \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ChatGPT",
    "description": "Advanced conversational AI",
    "url": "https://chat.openai.com",
    "submitted_by": "admin",
    "categories": [1, 2],
    "roles": ["frontend", "backend", "user"]
  }'
```

#### 3. Supported AI Tool Types
- **Conversational AI**: ChatGPT, Claude, Gemini
- **Code Assistants**: GitHub Copilot, Cursor, Codeium
- **Image Generation**: DALL-E, Midjourney, Stable Diffusion
- **Development Tools**: AI-powered IDEs, debugging tools
- **Content Creation**: Writing assistants, video generators
- **Data Analysis**: AI analytics tools, ML platforms

### Bot Integration Examples

#### Development Agent Setup
```javascript
// Initial prompt for Development Agent
const developmentAgentPrompt = `
You are a Development Agent specialized in full-stack development.
Your role includes:
- Code review and optimization
- Bug detection and fixing
- Architecture recommendations
- Performance analysis
- Security vulnerability assessment

Tech Stack:
- Frontend: Next.js, React, TypeScript, Tailwind CSS
- Backend: Laravel, PHP 8.2, MySQL, Redis
- Infrastructure: Docker, Nginx

Always provide:
1. Clear explanations
2. Code examples
3. Best practices
4. Security considerations
`;
```

#### AI Code Review Bot
```javascript
// Code review bot configuration
const codeReviewBot = {
  name: "AI Code Reviewer",
  triggers: ["pull_request", "code_push"],
  rules: [
    "Check for security vulnerabilities",
    "Verify code style compliance",
    "Analyze performance implications",
    "Suggest optimizations"
  ],
  integrations: ["github", "gitlab", "bitbucket"]
};
```

## 👥 Role System & Permissions

### User Roles

#### 1. Owner (Super Admin)
- **Full system access**
- Manage all users and roles
- Approve/reject tool submissions
- Access audit logs
- System configuration
- Export data

**Permissions:**
```php
'owner' => [
    'tools.create', 'tools.read', 'tools.update', 'tools.delete',
    'users.manage', 'roles.manage', 'categories.manage',
    'admin.dashboard', 'admin.audit', 'admin.export',
    'ratings.moderate', 'comments.moderate'
]
```

#### 2. Frontend Developer
- **Frontend-focused tools**
- Submit tools for approval
- Rate and comment on tools
- Access frontend-specific resources

**Permissions:**
```php
'frontend' => [
    'tools.create', 'tools.read', 'tools.update_own',
    'categories.read', 'ratings.create', 'comments.create',
    'tools.filter_by_role.frontend'
]
```

#### 3. Backend Developer
- **Backend-focused tools**
- Submit tools for approval
- Rate and comment on tools
- Access backend-specific resources

**Permissions:**
```php
'backend' => [
    'tools.create', 'tools.read', 'tools.update_own',
    'categories.read', 'ratings.create', 'comments.create',
    'tools.filter_by_role.backend'
]
```

#### 4. User (General)
- **Browse approved tools**
- Rate and comment on tools
- Basic tool submission

**Permissions:**
```php
'user' => [
    'tools.read', 'tools.create_basic',
    'ratings.create', 'comments.create'
]
```

### Role-Based Navigation

The system automatically adjusts navigation based on user roles:

```typescript
// Navigation items by role
const navigationItems = {
  owner: ['Dashboard', 'All Tools', 'Admin Panel', 'Users', 'Audit Logs'],
  frontend: ['Dashboard', 'Frontend Tools', 'My Tools', 'Add Tool'],
  backend: ['Dashboard', 'Backend Tools', 'My Tools', 'Add Tool'],
  user: ['Browse Tools', 'My Ratings', 'Add Tool']
};
```

### Permission Middleware

```php
// Laravel middleware for role-based access
Route::middleware(['auth:sanctum', 'role:owner'])->group(function () {
    Route::get('/admin/stats', [AdminController::class, 'stats']);
    Route::post('/admin/tools/{tool}/approve', [AdminController::class, 'approveTool']);
});

Route::middleware(['auth:sanctum', 'role:frontend,backend'])->group(function () {
    Route::post('/ai-tools', [AIToolController::class, 'store']);
});
```

## 🤖 AI Agents Documentation

### Development Agent

The Development Agent is an AI assistant specialized in full-stack development tasks.

#### Initial Setup Prompts

```markdown
# Development Agent - Initial Prompt

You are a Development Agent for the AI Tools Management Platform.

## Your Capabilities:
- Full-stack development (Next.js, Laravel, Docker)
- Code review and optimization
- Security analysis
- Performance monitoring
- Database management
- API development

## Project Context:
- Frontend: Next.js 15.4.6 + React 19 + TypeScript + Tailwind CSS
- Backend: Laravel 12 + PHP 8.2 + MySQL 8.0 + Redis 7
- Infrastructure: Docker Compose + Nginx
- Authentication: Laravel Sanctum + 2FA
- Features: Role-based access, ratings, comments, audit logs

## Your Tasks:
1. Code review and suggestions
2. Bug identification and fixes
3. Performance optimization
4. Security vulnerability assessment
5. Architecture improvements
6. Documentation updates

## Response Format:
Always provide:
- Clear problem analysis
- Step-by-step solutions
- Code examples with explanations
- Best practices recommendations
- Security considerations
- Testing suggestions
```

#### Specialized Agent Prompts

**Code Review Agent:**
```markdown
# Code Review Agent

Focus on:
- Security vulnerabilities (XSS, SQL injection, CSRF)
- Performance bottlenecks
- Code quality and maintainability
- TypeScript type safety
- Laravel best practices
- Database query optimization
```

**Security Agent:**
```markdown
# Security Agent

Analyze for:
- Authentication and authorization flaws
- Input validation issues
- Data exposure risks
- API security vulnerabilities
- Docker security configurations
- Environment variable security
```

**Performance Agent:**
```markdown
# Performance Agent

Monitor and optimize:
- Database query performance
- Frontend bundle size
- API response times
- Caching strategies
- Memory usage
- Docker container efficiency
```

### Agent Integration Examples

#### GitHub Actions Integration
```yaml
# .github/workflows/ai-review.yml
name: AI Code Review
on: [pull_request]
jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: AI Code Review
        run: |
          curl -X POST ${{ secrets.AI_AGENT_URL }}/review \
            -H "Authorization: Bearer ${{ secrets.AI_TOKEN }}" \
            -d @changes.diff
```

#### Slack Bot Integration
```javascript
// Slack bot for AI agent notifications
const { App } = require('@slack/bolt');

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET
});

app.message('review code', async ({ message, say }) => {
  const review = await aiAgent.reviewCode(message.text);
  await say(`🤖 AI Review: ${review.summary}`);
});
```

## 💬 Comments & Ratings System

### Features
- ⭐ 5-star rating system
- 💬 Detailed comments (up to 1000 characters)
- 👍 Helpful rating for comments
- 📊 Rating distribution analytics
- 🔒 User-based permissions
- 📈 Trending and sorting options

### API Endpoints

```bash
# Get tool ratings
GET /api/tools/{toolId}/ratings?sort=recent&min_rating=4

# Submit rating
POST /api/tools/{toolId}/rate
{
  "rating": 5,
  "comment": "Excellent tool for development!"
}

# Mark rating as helpful
POST /api/ratings/{ratingId}/helpful

# Delete rating (owner or admin only)
DELETE /api/ratings/{ratingId}

# Get tool statistics
GET /api/tools/{toolId}/stats
```

### Frontend Components

```typescript
// Usage example
import { ToolRatings } from '@/components/ToolRatings';

<ToolRatings 
  toolId={tool.id} 
  currentUser={user} 
/>
```

### Rating Analytics

The system provides comprehensive analytics:
- Average rating calculation
- Rating distribution (1-5 stars)
- Most helpful comments
- Recent activity tracking
- User engagement metrics

## 🔧 Development

### Local Development Setup

```bash
# Frontend development
cd frontend
npm install
npm run dev

# Backend development
cd backend
composer install
php artisan serve

# Database migrations
php artisan migrate
php artisan db:seed
```

### Code Quality Tools

```bash
# Frontend linting
npm run lint

# Backend code style
./vendor/bin/pint

# Type checking
npm run type-check

# Testing
npm test
php artisan test
```

### API Documentation

The API follows RESTful conventions with comprehensive error handling:

```typescript
// Error handling example
try {
  const tools = await getAITools();
} catch (error) {
  console.error('API Error:', error.message);
  // Handle error appropriately
}
```

## 🔒 Security Features

### Authentication
- Laravel Sanctum token-based auth
- Multi-factor authentication (2FA)
- Email, Telegram, Google Authenticator support
- Session management

### Authorization
- Role-based access control (RBAC)
- Permission-based middleware
- Resource ownership validation
- API rate limiting

### Data Protection
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CSRF token validation
- Secure headers configuration

## 📊 Monitoring & Analytics

### Audit Logging
All user actions are logged for security and compliance:
- User authentication events
- Tool creation/modification
- Rating submissions
- Administrative actions
- Failed access attempts

### Performance Monitoring
- API response time tracking
- Database query analysis
- Cache hit/miss ratios
- Error rate monitoring
- User activity analytics

## 🚀 Deployment

### Production Deployment

```bash
# Build for production
docker compose -f docker-compose.prod.yml up -d

# Environment variables
cp .env.example .env
# Configure production settings

# SSL/TLS setup
# Configure reverse proxy (Nginx/Apache)
# Set up domain and certificates
```

### Scaling Considerations
- Database connection pooling
- Redis clustering for cache
- Load balancer configuration
- CDN for static assets
- Horizontal scaling with Docker Swarm/Kubernetes

## 📚 Additional Resources

### Documentation Files
- [PHASE4_FINAL_SUMMARY.md](./PHASE4_FINAL_SUMMARY.md) - Project overview
- [UI_UX_ENHANCEMENTS.md](./UI_UX_ENHANCEMENTS.md) - UI/UX documentation
- [PHASE4_IMPLEMENTATION_GUIDE.md](./PHASE4_IMPLEMENTATION_GUIDE.md) - Implementation guide
- [ARCHITECTURE_DIAGRAM.md](./ARCHITECTURE_DIAGRAM.md) - System architecture

### Support
- GitHub Issues: Report bugs and feature requests
- Documentation: Comprehensive guides and API reference
- Community: Join our Discord/Slack for discussions

---

**Last Updated**: 2026-01-17  
**Version**: 4.0.0  
**License**: MIT