# AI Tools Management System - Quick Start Guide

## 🚀 Getting Started in 3 Minutes

### Access the Application

**Frontend:** http://localhost:8200  
**Backend API:** http://localhost:8201/api  
**Database:** localhost:8203

---

## 📋 Pre-Seeded Data

### Demo Accounts
```
User: Ivan Ivanov (Owner)
Email: ivan@admin.local
Password: password
Role: owner

User: Elena Petrova (Frontend Developer)
Email: elena@frontend.local
Password: password
Role: frontend

User: Peter Georgiev (Backend Developer)
Email: petar@backend.local
Password: password
Role: backend
```

### Pre-Loaded Categories (8 total)
- Code Generation
- Writing & Documentation
- Data Analysis
- Design & Creativity
- Productivity
- DevOps & Deployment
- Testing & QA
- API & Integration

### Pre-Loaded Tools (10 total)
- GitHub Copilot
- ChatGPT
- Claude
- Figma
- Jira with AI
- Docker & Kubernetes
- Jest
- Postman
- Tableau
- Grammarly

---

## 🎯 Common Tasks

### 1. Browse AI Tools
1. Visit http://localhost:8200
2. View all tools in grid layout
3. Click category buttons to filter
4. Click tool URLs to learn more

### 2. Add a New Tool
1. Click "+ Add Tool" button (requires login)
2. If not logged in:
   - Click "Login" button
   - Enter: `ivan@admin.local` / `password`
3. Fill in the form:
   - **Tool Name**: e.g., "Hugging Face"
   - **Description**: What does it do?
   - **URL**: https://huggingface.co (optional)
   - **Your Name**: Who submitted it
   - **Categories**: Select existing or create new
   - **Roles**: Select target audience
4. Click "Create Tool"

### 3. Filter Tools by Category
1. Click any category button at the top
2. View only tools in that category
3. Click "All Tools" to see everything again

### 4. Filter Tools by Role
- Use API: `GET /api/ai-tools/role/{role}`
- Roles: `owner`, `frontend`, `backend`, `user`

### 5. Delete a Tool
1. Login first
2. Find the tool in the catalog
3. Click "Delete" button
4. Confirm deletion

---

## 🔌 API Quick Reference

### Get All Tools
```bash
curl http://localhost:8201/api/ai-tools | jq
```

### Get Single Tool
```bash
curl http://localhost:8201/api/ai-tools/1 | jq
```

### Get All Categories
```bash
curl http://localhost:8201/api/categories | jq
```

### Get Tools by Role
```bash
# Backend developers
curl http://localhost:8201/api/ai-tools/role/backend | jq

# Frontend developers
curl http://localhost:8201/api/ai-tools/role/frontend | jq

# Owners
curl http://localhost:8201/api/ai-tools/role/owner | jq
```

### Get Tools by Category
```bash
# Get category ID first
curl http://localhost:8201/api/categories | jq

# Then get tools from that category (e.g., ID=1)
curl http://localhost:8201/api/ai-tools/category/1 | jq
```

### Create New Tool
```bash
curl -X POST http://localhost:8201/api/ai-tools \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Tool",
    "description": "Tool description",
    "url": "https://example.com",
    "submitted_by": "Your Name",
    "categories": [1, 2],
    "roles": ["backend", "frontend"]
  }'
```

### Create Category
```bash
curl -X POST http://localhost:8201/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Machine Learning",
    "description": "ML and AI tools"
  }'
```

### Delete Tool
```bash
curl -X DELETE http://localhost:8201/api/ai-tools/1
```

---

## 📁 File Locations

### Backend
- **Models**: `backend/app/Models/`
  - `AITool.php`
  - `Category.php`
  - `ToolRole.php`
- **Controller**: `backend/app/Http/Controllers/AIToolController.php`
- **Routes**: `backend/routes/api.php`
- **Migrations**: `backend/database/migrations/`
- **Seeders**: `backend/database/seeders/`

### Frontend
- **API Client**: `frontend/src/lib/api.ts`
- **Components**: `frontend/src/components/`
  - `ToolsList.tsx`
  - `ToolForm.tsx`
  - `Header.tsx`
- **Pages**: `frontend/src/app/page.tsx`

---

## 🛠️ Docker Commands

### Restart all services
```bash
docker compose restart
```

### View logs
```bash
# All logs
docker compose logs -f

# Backend logs
docker compose logs -f php_fpm

# Frontend logs
docker compose logs -f frontend

# Database logs
docker compose logs -f mysql
```

### SSH into containers
```bash
# Backend PHP
docker compose exec php_fpm bash

# Frontend Node
docker compose exec frontend sh

# MySQL
docker compose exec mysql mysql -u root -p
```

### Reset database
```bash
# Drop and recreate
docker compose exec php_fpm php artisan migrate:fresh

# Reseed
docker compose exec php_fpm php artisan db:seed --class=CategorySeeder
docker compose exec php_fpm php artisan db:seed --class=AIToolSeeder
```

---

## 🔍 Troubleshooting

### Frontend not loading
- Check if running on http://localhost:8200
- Check frontend logs: `docker compose logs frontend`
- Restart frontend: `docker compose restart frontend`

### API returning 500 error
- Check backend logs: `docker compose logs php_fpm`
- Verify database connection: `docker compose logs mysql`
- Run migrations: `docker compose exec php_fpm php artisan migrate`

### Can't connect to database
- Verify MySQL is running: `docker compose ps mysql`
- Check credentials in `.env`
- Restart MySQL: `docker compose restart mysql`

### Tool form validation errors
- Ensure all required fields are filled
- Select at least one category
- Select at least one role
- Check browser console for errors: `Ctrl+F12`

---

## 📊 Database Schema

```
ai_tools (10 records)
├── id
├── name
├── description
├── url
├── submitted_by
├── user_id (FK)
├── created_at
└── updated_at

categories (8 records)
├── id
├── name
├── description
├── slug
├── created_at
└── updated_at

tool_category (13 records) [Pivot]
├── id
├── ai_tool_id (FK)
├── category_id (FK)
├── created_at
└── updated_at

tool_role (30+ records)
├── id
├── ai_tool_id (FK)
├── role
├── created_at
└── updated_at
```

---

## 💡 Tips

✅ **Category Filtering Works Best When:**
- Multiple tools share categories
- You use meaningful category names
- You keep categories count reasonable

✅ **Role Management:**
- Tools should cover multiple roles for discoverability
- Use predefined roles consistently
- Filter by role in API for team-specific recommendations

✅ **Performance:**
- Categories load once and are cached
- Tools load on page initialization
- API responses include full relationships

✅ **User Experience:**
- Tool URLs open in new tabs
- Cards are hoverable with shadows
- Empty states guide users
- Error messages are clear

---

## 🚀 Next Steps

1. **Explore**: Browse the pre-loaded tools and categories
2. **Test**: Try the API endpoints in your terminal
3. **Create**: Add a new tool through the UI
4. **Integrate**: Use the API in your own applications
5. **Extend**: Add more features and customizations

---

## 📚 Documentation

For detailed documentation, see:
- [AI_TOOLS_MANAGEMENT.md](./AI_TOOLS_MANAGEMENT.md) - Complete system documentation
- [FRONTEND_SETUP.md](./FRONTEND_SETUP.md) - Frontend setup and components
- [README.md](./README.md) - General project information

---

**Happy Tool Discovering! 🎉**
