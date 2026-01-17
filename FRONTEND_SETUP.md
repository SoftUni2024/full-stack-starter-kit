# Frontend Layout & Authentication Guide

## Overview

This is a modern React/Next.js frontend built with Tailwind CSS that connects to the Laravel backend API. The application features a professional header layout with login functionality and displays user information when logged in.

## Features

### 1. **Header Layout**
- **Logo & Branding**: VibeCode logo with gradient background in the top-left
- **Current Time Display**: Shows the system time in the center, updating every second
- **User Status**: Displays logged-in user information with avatar
- **Login/Logout Buttons**: Easy authentication toggle

### 2. **Login Functionality**
- Modal-based login interface
- Email/password authentication
- Error handling with user feedback
- Demo accounts information displayed in the modal
- Automatic localStorage persistence of user data

### 3. **API Integration**
- Connected to Laravel backend at `http://localhost:8201/api`
- Login endpoint: `POST /api/login`
- Automatic token/user state management
- Error handling for network and validation errors

## Project Structure

```
frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx         # Root layout with global styles
│   │   ├── page.tsx           # Main page with header integration
│   │   ├── globals.css        # Global CSS
│   │   └── favicon.ico
│   ├── components/
│   │   ├── Header.tsx         # Main header component
│   │   └── LoginModal.tsx     # Login modal component
│   └── lib/
│       └── api.ts             # API client utilities
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

## Components

### Header Component (`src/components/Header.tsx`)

**Props:**
- `user: User | null` - Currently logged-in user
- `onLoginSuccess: (user: User) => void` - Callback when login succeeds
- `onLogout: () => void` - Callback when user logs out

**Features:**
- Real-time clock display
- User profile card with role and ID
- Login/Logout buttons
- Responsive design

### LoginModal Component (`src/components/LoginModal.tsx`)

**Props:**
- `isOpen: boolean` - Modal visibility state
- `onClose: () => void` - Close modal callback
- `onLogin: (email: string, password: string) => Promise<void>` - Login handler
- `isLoading?: boolean` - Loading state
- `error?: string` - Error message display

**Features:**
- Email and password inputs
- Demo account credentials displayed
- Error message display
- Loading state handling

## API Integration (`src/lib/api.ts`)

### Types

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: string;
}

interface LoginCredentials {
  email: string;
  password: string;
}

interface LoginResponse {
  message: string;
  user: User;
}
```

### Functions

- `login(credentials: LoginCredentials): Promise<LoginResponse>` - Authenticate user
- `logout(): Promise<void>` - Logout user
- `saveUser(user: User): void` - Save user to localStorage
- `loadUser(): User | null` - Load user from localStorage
- `clearUser(): void` - Clear user from localStorage

## Demo Accounts

Three demo accounts are pre-seeded in the database:

1. **Ivan Ivanov** (Owner)
   - Email: `ivan@admin.local`
   - Password: `password`
   - Role: `owner`

2. **Elena Petrova** (Frontend Developer)
   - Email: `elena@frontend.local`
   - Password: `password`
   - Role: `frontend`

3. **Peter Georgiev** (Backend Developer)
   - Email: `petar@backend.local`
   - Password: `password`
   - Role: `backend`

## Usage

### Starting the Development Server

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:8200` (as configured in docker-compose.yml).

### Building for Production

```bash
npm run build
npm run start
```

### Environment Variables

```bash
# .env.local (optional)
NEXT_PUBLIC_API_URL=http://localhost:8201/api
```

## How to Use

1. **View Current Time**: The header displays the current time in real-time
2. **Login**: Click the "Login" button in the header
3. **Enter Credentials**: Use one of the demo accounts to log in
4. **View User Info**: After login, see your name, role, and ID in the header
5. **Logout**: Click the "Logout" button to clear your session

## Authentication Flow

```
1. User clicks "Login" button
   ↓
2. LoginModal opens
   ↓
3. User enters credentials
   ↓
4. Submit form → API call to /api/login
   ↓
5. Backend validates credentials
   ↓
6. If valid → User data returned and stored in localStorage
   ↓
7. Header displays user info
   ↓
8. Click "Logout" → User data cleared from localStorage
```

## Styling

- **Framework**: Tailwind CSS v4
- **Colors**: 
  - Primary: Blue (`#2563eb`)
  - Secondary: Purple (gradient)
  - Neutral: Gray scale
- **Typography**: 
  - Sans: Inter
  - Mono: JetBrains Mono

## State Management

User state is managed through:
- **React Hooks** (`useState`, `useEffect`)
- **localStorage** - Persists user data across page refreshes
- **API calls** - Communicates with Laravel backend

When the page loads:
1. Attempts to load user from localStorage
2. Sets initial user state
3. Fetches AI tools from backend
4. Updates in real-time when login/logout occurs

## Error Handling

- Network errors: User-friendly error messages displayed in modal
- Invalid credentials: "The provided credentials are incorrect" message
- Loading states: Buttons disabled during API calls

## Next Steps

To extend this application:

1. **Add Protected Routes**: Redirect to login if `user` is null
2. **Token-Based Auth**: Implement JWT token storage and API header injection
3. **Additional Pages**: Create more routes within the app layout
4. **User Profile**: Add a dedicated profile page
5. **Role-Based Access**: Implement permission checks based on user role
