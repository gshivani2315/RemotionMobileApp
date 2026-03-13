# ReMotion Backend - Quick Setup Guide

## Firebase Integration Complete ✅

The backend is now fully integrated with Firebase Firestore for persistent data storage.

## What Changed

### New Files Created
1. **`services/firebaseService.js`** - Firestore database service with helper functions
2. **`controllers/progressController.js`** - Progress data controller using Firestore
3. **`controllers/dashboardController.js`** - Dashboard stats controller using Firestore
4. **`FIRESTORE_SETUP.md`** - Complete Firestore structure and setup documentation

### Updated Files
1. **`routes/progress.js`** - Now uses controllers instead of mock data
2. **`routes/dashboard.js`** - Now uses controller with Firestore
3. **`controllers/userController.js`** - Now stores user profiles in Firestore

## Quick Setup Steps

### 1. Firebase Configuration (If not already done)

You mentioned you have a Firebase backend for your web app. You can use the **same Firebase project** for this mobile app!

**Download Service Account Key:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings ⚙️ > Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file in your backend folder (e.g., `firebase-service-account.json`)

### 2. Environment Variables

Create or update `.env.development.local`:

```bash
# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Server Configuration
PORT=3000
NODE_ENV=development

# CORS - Add your frontend URLs
ALLOWED_ORIGINS=http://localhost:3000,http://10.0.2.2:3000
```

For production, create `.env.production.local`:

```bash
# For deployed environments, use JSON string instead of file path
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"your-project-id",...}'

PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com
```

### 3. Firestore Security Rules

In Firebase Console > Firestore Database > Rules, set:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /progress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Start Backend

```bash
cd backend
npm install
npm run dev
```

### 5. Test the Mobile App

1. Start the backend (step 4)
2. Open the Flutter app
3. Log in with Firebase Auth
4. Navigate to Progress page
5. Data will be automatically initialized if it's your first time!

## API Endpoints

### Progress
- `GET /api/progress` - Get all progress data (creates default if doesn't exist)
- `POST /api/progress/level-up-seen` - Mark level-up as viewed
- `PUT /api/progress/update` - Update progress fields
- `POST /api/progress/reset` - Reset to defaults (for testing)

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics

### User
- `GET /api/profile` - Get user profile (creates if doesn't exist)

## Data Flow

1. **User logs in** → Firebase Auth creates token
2. **App makes API request** → Backend verifies token
3. **First request** → If user/progress data doesn't exist, initialize with defaults
4. **Subsequent requests** → Read/write from Firestore

## Firestore Collections

- **`users`** - User profiles
- **`progress`** - User progress data (recovery level, streaks, achievements, etc.)

See [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) for complete data structure.

## Testing Different States

### Reset Progress Data
```bash
curl -X POST http://localhost:3000/api/progress/reset \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update Specific Fields
```bash
curl -X PUT http://localhost:3000/api/progress/update \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "levelUp": {
      "currentLevel": 5,
      "streak": 10,
      "showLevelUp": true
    }
  }'
```

## Sharing Firebase Project with Web App

Since you mentioned using the same Firebase backend for both web and mobile:

✅ **This works perfectly!** Both apps can share:
- Same Firebase project
- Same Firestore database
- Same Authentication users
- Same security rules

Just make sure:
1. Both apps use the same Firebase project credentials
2. Add both app platforms in Firebase Console (Web + Android/iOS)
3. Firestore rules allow access based on user ID, not platform

## Troubleshooting

### "No Firebase service account configured" error
- Check that `.env.development.local` exists
- Verify `FIREBASE_SERVICE_ACCOUNT_PATH` points to correct file
- Or use `FIREBASE_SERVICE_ACCOUNT_JSON` with full JSON string

### "Invalid token" errors
- User's Firebase Auth token may be expired
- App should refresh token automatically
- Check token expiration in `authMiddleware.js`

### Data not showing in app
- Check browser console / app logs for errors
- Verify Firestore rules allow access
- Test endpoints with curl/Postman first
- Check that user is logged in and token is valid

## Next Steps

1. ✅ Backend integrated with Firestore
2. ✅ Progress page pulls real data
3. ✅ Auto-initialization for new users
4. 🔄 Add more endpoints as needed (sessions, exercises, etc.)
5. 🔄 Implement data sync for offline mode
6. 🔄 Add push notifications for streaks

## Questions?

See [FIRESTORE_SETUP.md](./FIRESTORE_SETUP.md) for detailed documentation on:
- Complete Firestore schema
- Security rules setup
- Data migration strategies
- API endpoint details
