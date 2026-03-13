# Firebase Firestore Data Structure

This document describes the Firestore database structure for the ReMotion mobile app backend.

## Collections

### 1. `users` Collection
Stores basic user profile information.

**Document ID:** Firebase Auth UID

```javascript
{
  uid: string,              // Firebase Auth UID
  email: string,            // User email
  displayName: string,      // User's display name
  createdAt: timestamp,     // Account creation timestamp
  updatedAt: timestamp      // Last update timestamp
}
```

### 2. `progress` Collection
Stores comprehensive user progress and recovery data.

**Document ID:** Firebase Auth UID

```javascript
{
  userId: string,           // Firebase Auth UID
  
  // Level Up Data
  levelUp: {
    currentLevel: number,   // User's current recovery level (1-10)
    streak: number,         // Current active streak days
    message: string,        // Level up celebration message
    achievement: string,    // Achievement name
    showLevelUp: boolean    // Whether to show level-up overlay
  },
  
  // Recovery Level Data
  recoveryLevel: {
    level: number,          // Current level (1-10)
    percentage: number,     // Progress to next level (0.0-1.0)
    xp: {
      current: number,      // Current XP points
      max: number           // XP needed for next level
    },
    stats: {
      sleepQuality: number,  // 0.0-1.0
      hydration: number,     // 0.0-1.0
      mobility: number       // 0.0-1.0
    }
  },
  
  // Streak Data
  streak: {
    days: number,           // Total active streak days
    isActive: boolean,      // Whether streak is currently active
    lastActivityDate: string // ISO date of last activity
  },
  
  // Timeline Progress
  timeline: [
    {
      label: string,        // Milestone label (e.g., "STARTED", "WEEK 1")
      icon: string,         // Icon name (e.g., "eco", "fire", "diamond")
      completed: boolean,   // Whether milestone is completed
      current: boolean      // Whether this is the current milestone
    }
  ],
  
  // Body Map Data
  bodyMap: {
    zones: [
      {
        area: string,       // Body area (e.g., "shoulders", "torso", "legs")
        status: string,     // Status: "focus", "good", "rest"
        intensity: number   // Intensity level (0.0-1.0)
      }
    ]
  },
  
  // Movement Quality Data
  movementQuality: {
    flexibility: {
      value: number,        // 0-100 percentage
      label: string         // "FLEXIBILITY"
    },
    strength: {
      value: number,        // 0-100 percentage
      label: string         // "STRENGTH"
    },
    endurance: {
      value: number,        // 0-100 percentage
      label: string         // "ENDURANCE"
    },
    balance: {
      value: number,        // 0-100 percentage
      label: string         // "BALANCE"
    }
  },
  
  // Achievements
  achievements: {
    total: number,          // Total number of achievements
    unlocked: number,       // Number of unlocked achievements
    progress: number,       // Overall progress (0.0-1.0)
    badges: [
      {
        id: string,         // Unique achievement ID
        name: string,       // Achievement name
        icon: string,       // Icon name
        unlocked: boolean   // Whether unlocked
      }
    ]
  },
  
  // Physio Note
  physioNote: {
    message: string,        // Note message from physiotherapist
    author: string,         // Author name (e.g., "Dr. Sarah M.")
    date: string           // ISO date string
  },
  
  createdAt: timestamp,    // Document creation timestamp
  updatedAt: timestamp     // Last update timestamp
}
```

### 3. `sessions` Collection (Future)
Will store workout/therapy session data.

```javascript
{
  userId: string,           // Firebase Auth UID
  sessionType: string,      // Type of session
  startTime: timestamp,     // Session start
  endTime: timestamp,       // Session end
  exercises: array,         // List of exercises performed
  notes: string            // Session notes
}
```

### 4. `achievements` Collection (Future)
Will store achievement definitions and unlock criteria.

```javascript
{
  id: string,              // Achievement ID
  name: string,            // Achievement name
  description: string,     // Achievement description
  icon: string,            // Icon name
  criteria: object         // Unlock criteria
}
```

## API Endpoints

### Progress Endpoints

- **GET** `/api/progress` - Get user's complete progress data
- **POST** `/api/progress/level-up-seen` - Mark level-up notification as viewed
- **PUT** `/api/progress/update` - Update specific progress fields
- **POST** `/api/progress/reset` - Reset progress to defaults (dev/testing)

### Dashboard Endpoints

- **GET** `/api/dashboard/stats` - Get basic dashboard statistics

### User Endpoints

- **GET** `/api/profile` - Get user profile data

## Firebase Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Enable Firestore Database in your project

### 2. Enable Authentication
1. Go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Enable any other providers you want (Google, etc.)

### 3. Firestore Security Rules
Set up security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /progress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Configure Backend

1. Download your Firebase service account key:
   - Go to Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file securely

2. Set up environment variables in `.env.development.local` and `.env.production.local`:

```bash
# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./path/to/serviceAccountKey.json
# OR use JSON directly (for deployed environments):
# FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'

# Server Configuration
PORT=3000
NODE_ENV=development

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://10.0.2.2:3000
```

### 5. Initialize User Data

When a user first logs in:
1. The backend automatically creates a progress document with default values
2. The `initializeUserProgress()` function in `firebaseService.js` handles this
3. All subsequent API calls will read/update this data

## Testing

### Test Progress Data Creation
1. Log in from the mobile app
2. Navigate to the Progress page
3. If this is your first time, default progress data will be created automatically
4. Use `/api/progress/reset` endpoint to reset data for testing different states

### Updating Progress Data
Use the Firebase Console or make API calls to update specific fields:

```javascript
// Example: Update movement quality
PUT /api/progress/update
{
  "movementQuality": {
    "flexibility": { "value": 85, "label": "FLEXIBILITY" },
    "strength": { "value": 70, "label": "STRENGTH" }
  }
}
```

## Data Migration

If you have existing data in another database:
1. Export your data
2. Transform to match the schema above
3. Use Firebase Admin SDK batch writes to import
4. Script example in `/scripts/migrate-data.js` (create as needed)

## Notes

- All timestamps use Firestore's `FieldValue.serverTimestamp()`
- Progress data is automatically initialized on first access
- User IDs are Firebase Auth UIDs for consistency
- The mobile app and web app can share the same Firebase project
