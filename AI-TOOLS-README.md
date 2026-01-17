# AI Tools Hub

Internal platform for teams to discover and share AI tools, libraries, and applications.

## Features

- 📋 Browse all shared AI tools
- ➕ Submit new tools with details
- 🔍 Search by name, category, or team
- 🏷️ Categorize tools for easy discovery
- 👥 Track which team shared each tool

## Quick Start

1. **Start the environment:**
   ```bash
   ./start.sh
   ```

2. **Setup the platform:**
   ```bash
   ./setup-ai-tools.sh
   ```

3. **Access the platform:**
   - Frontend: http://localhost:8200
   - API: http://localhost:8201/api/ai-tools

## Usage

### Adding a Tool
1. Click "+ Add Tool"
2. Fill in:
   - Tool name
   - Category (e.g., "Code Generation", "Image AI", "Data Analysis")
   - Description
   - URL (optional)
   - Your name
   - Your team
3. Submit

### Searching
Use the search bar to filter by tool name, category, or team.

## API Endpoints

- `GET /api/ai-tools` - List all tools
- `POST /api/ai-tools` - Create new tool
- `GET /api/ai-tools/{id}` - Get specific tool
- `DELETE /api/ai-tools/{id}` - Delete tool

## Database Schema

**ai_tools table:**
- id
- name
- category
- description
- url (nullable)
- submitted_by
- team
- created_at
- updated_at
