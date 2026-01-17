# AI Tools Management System

## Overview

The AI Tools Management System is a comprehensive platform for discovering, organizing, and managing AI tools within your organization. It provides a flexible structure with categories, role-based associations, and a user-friendly interface for both browsing and contributing tools.

## Features

### ✨ Core Features

1. **AI Tools Catalog**
   - Browse all available AI tools
   - Filter by category
   - View tool details (description, URL, roles)
   - Search functionality

2. **Categories System**
   - Pre-defined categories for organization
   - Create custom categories on-the-fly
   - One tool can belong to multiple categories

3. **Role-Based Association**
   - Associate tools with specific user roles (Owner, Frontend, Backend, User)
   - Filter tools by target audience/role
   - Easy role management

4. **CRUD Operations**
   - **Create**: Add new AI tools with categories and roles
   - **Read**: Browse tools in multiple ways
   - **Update**: Modify existing tools (planned)
   - **Delete**: Remove tools from catalog

5. **User Authentication**
   - Login/logout functionality
   - Role-based access control
   - User profile display

## Database Schema

### Tables

#### `ai_tools`
```sql
- id (PK)
- name (unique, required)
- description (text, required)
- url (optional)
- submitted_by (required)
- user_id (FK to users, optional)
- created_at
- updated_at
```

#### `categories`
```sql
- id (PK)
- name (unique, required)
- description (optional)
- slug (unique, required)
- created_at
- updated_at
```

#### `tool_category` (Pivot Table)
```sql
- id (PK)
- ai_tool_id (FK)
- category_id (FK)
- created_at
- updated_at
- UNIQUE: (ai_tool_id, category_id)
```

#### `tool_role` (One-to-Many with AI Tools)
```sql
- id (PK)
- ai_tool_id (FK)
- role (string: 'owner', 'frontend', 'backend', 'user')
- created_at
- updated_at
- UNIQUE: (ai_tool_id, role)
```

## API Endpoints

### Public Endpoints

#### Get All AI Tools
```
GET /api/ai-tools
Response: AITool[]
```

#### Get Single AI Tool
```
GET /api/ai-tools/{id}
Response: AITool
```

#### Get All Categories
```
GET /api/categories
Response: Category[]
```

#### Get Tools by Category
```
GET /api/ai-tools/category/{categoryId}
Response: AITool[]
```

#### Get Tools by Role
```
GET /api/ai-tools/role/{role}
Parameters: role = 'owner' | 'frontend' | 'backend' | 'user'
Response: AITool[]
```

### Protected Endpoints (Requires Authentication)

#### Create AI Tool
```
POST /api/ai-tools
Body: {
  name: string,
  description: string,
  url: string | null,
  submitted_by: string,
  categories: number[],
  roles: string[]
}
Response: { message: string, tool: AITool }
```

#### Update AI Tool
```
PUT /api/ai-tools/{id}
Body: Same as Create
Response: { message: string, tool: AITool }
```

#### Delete AI Tool
```
DELETE /api/ai-tools/{id}
Response: { message: string }
```

#### Create Category
```
POST /api/categories
Body: {
  name: string,
  description?: string
}
Response: { message: string, category: Category }
```

## Frontend Components

### ToolsList Component
Displays all AI tools with filtering capabilities.

**Props:**
- `user` - Current logged-in user
- `onAddClick` - Callback when user clicks Add Tool
- `refreshTrigger` - Number to trigger refresh

**Features:**
- Grid layout with 3 columns
- Category filtering
- Delete functionality
- Empty state handling
- Responsive design

### ToolForm Component
Modal form for adding new AI tools.

**Props:**
- `isOpen` - Whether form is visible
- `onClose` - Close callback
- `onSuccess` - Success callback
- `isLoading` - Loading state
- `setIsLoading` - Set loading state
- `error` - Error message
- `setError` - Set error message

**Features:**
- Tool name, description, URL fields
- Category selection with multi-select
- Create new categories inline
- Role selection with multi-select
- Submission handling
- Error display
- Loading states

### Header Component
Main navigation header with authentication.

**Features:**
- Logo/branding
- Real-time clock
- User profile (when logged in)
- Login/Logout functionality
- Responsive design

## Seeded Data

### Pre-Loaded Categories
1. Code Generation
2. Writing & Documentation
3. Data Analysis
4. Design & Creativity
5. Productivity
6. DevOps & Deployment
7. Testing & QA
8. API & Integration

### Pre-Loaded AI Tools
10 popular AI tools are seeded, including:
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

Each tool is associated with appropriate categories and roles.

## Usage Guide

### For End Users

#### Browsing Tools
1. Visit the AI Tools Catalog
2. See all tools in a grid layout
3. Click category buttons to filter
4. Click "Visit Website" to access tool links

#### Adding a Tool
1. Click "+ Add Tool" button (requires login)
2. Fill in tool information:
   - Tool Name *
   - Description *
   - URL (optional)
   - Your Name (optional)
3. Select categories (at least one required)
4. Select target roles (at least one required)
5. Click "Create Tool"

#### Managing Tools
- **Edit**: Click "Edit" button (planned feature)
- **Delete**: Click "Delete" button and confirm

### For Developers

#### Setting Up

1. **Ensure all migrations are run:**
   ```bash
   docker compose exec php_fpm php artisan migrate
   ```

2. **Seed database with categories and tools:**
   ```bash
   docker compose exec php_fpm php artisan db:seed --class=CategorySeeder
   docker compose exec php_fpm php artisan db:seed --class=AIToolSeeder
   ```

3. **Access the application:**
   - Frontend: http://localhost:8200
   - Backend API: http://localhost:8201/api
   - Database: localhost:8203

#### API Integration Example

```typescript
import { getAITools, createAITool, getCategories } from '@/lib/api';

// Get all tools
const tools = await getAITools();

// Get categories
const categories = await getCategories();

// Create a new tool
const newTool = await createAITool({
  name: 'My Tool',
  description: 'Tool description',
  url: 'https://example.com',
  submitted_by: 'John Doe',
  categories: [1, 2],
  roles: ['backend', 'frontend']
});
```

## Key Models & Relationships

### AITool Model
- **hasMany**: `roles` (ToolRole)
- **belongsToMany**: `categories` (Category via tool_category)

### Category Model
- **belongsToMany**: `aiTools` (AITool via tool_category)

### ToolRole Model
- **belongsTo**: `aiTool` (AITool)

## Validation Rules

### Creating an AI Tool
- **name**: Required, max 255 characters, unique
- **description**: Required, text
- **url**: Optional, must be valid URL
- **submitted_by**: Required, max 255 characters
- **categories**: Array, at least one category ID must exist
- **roles**: Array, valid roles are: 'owner', 'frontend', 'backend', 'user'

### Creating a Category
- **name**: Required, max 255 characters, unique
- **description**: Optional, text

## Future Enhancements

1. **Update Functionality**
   - Edit existing tools
   - Modify categories and roles

2. **Advanced Filtering**
   - Search by name/description
   - Filter by multiple roles
   - Sort by date/popularity

3. **User Contributions**
   - Track which user submitted each tool
   - User profile pages
   - User-submitted tools listing

4. **Analytics**
   - Most viewed tools
   - Popular categories
   - Usage statistics

5. **Favorites/Bookmarks**
   - Save favorite tools
   - Create personal tool collections
   - Share collections with team

6. **Reviews & Ratings**
   - Rate tools
   - Leave comments
   - Community feedback

7. **Integration**
   - Direct tool launch from platform
   - API key management
   - Integration with IDE/code editor

## Testing

### Test the API

```bash
# Get all tools
curl http://localhost:8201/api/ai-tools

# Get categories
curl http://localhost:8201/api/categories

# Get tools by role
curl http://localhost:8201/api/ai-tools/role/backend

# Create a tool (requires login - implementation pending)
curl -X POST http://localhost:8201/api/ai-tools \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","description":"Test tool","categories":[1],"roles":["backend"],"submitted_by":"Test"}'
```

### Test the Frontend

1. Visit http://localhost:8200
2. View all tools in the catalog
3. Click on categories to filter
4. Login with demo account (ivan@admin.local / password)
5. Click "+ Add Tool" and try adding a new tool
6. Verify the tool appears in the catalog
7. Click "Delete" to remove a tool

## Architecture Notes

### Design Decisions

1. **Pivot Tables Instead of Single String Fields**
   - Categories: Many-to-many relationship (tool can have multiple categories)
   - Roles: One-to-many relationship (one tool has many role associations)

2. **Frontend-Driven UI**
   - Category selection on form
   - Create categories inline
   - Role selection with checkboxes

3. **API-First Approach**
   - All data managed through REST API
   - Frontend uses centralized API client
   - Easy to extend with mobile apps or other clients

4. **User Association**
   - Optional user_id field tracks who submitted tool
   - Allows future features like user profiles and reputation

## Performance Considerations

1. **Eager Loading**: API returns relationships with tools
2. **Unique Constraints**: Prevent duplicate tool-category/tool-role pairs
3. **Cascading Deletes**: Removing tool removes all associations

## Security Considerations

1. **Protected Routes**: Creating/updating/deleting tools requires authentication
2. **Validation**: All input validated on both frontend and backend
3. **Future**: Role-based authorization for tool management

## Troubleshooting

### Tools not appearing after creation
1. Check API response for errors
2. Verify categories and roles were sent
3. Check database for tool record

### Form validation errors
1. Ensure all required fields are filled
2. Select at least one category
3. Select at least one role

### Database connection issues
1. Verify MySQL container is running: `docker compose ps`
2. Check credentials in .env file
3. Run migrations: `docker compose exec php_fpm php artisan migrate`

## File Structure

```
backend/
  ├── app/Models/
  │   ├── AITool.php
  │   ├── Category.php
  │   └── ToolRole.php
  ├── app/Http/Controllers/
  │   └── AIToolController.php
  ├── database/
  │   ├── migrations/
  │   │   ├── 2025_01_09_000000_create_ai_tools_table.php
  │   │   ├── 2026_01_17_085325_create_categories_table.php
  │   │   ├── 2026_01_17_085325_create_tool_category_table.php
  │   │   ├── 2026_01_17_085325_create_tool_role_table.php
  │   │   └── 2026_01_17_085406_modify_ai_tools_table.php
  │   └── seeders/
  │       ├── CategorySeeder.php
  │       └── AIToolSeeder.php
  └── routes/
      └── api.php

frontend/
  └── src/
      ├── lib/
      │   └── api.ts
      └── components/
          ├── Header.tsx
          ├── ToolsList.tsx
          └── ToolForm.tsx
```

---

## Support & Contributions

For issues, questions, or suggestions, please refer to the main project documentation or contact the development team.
