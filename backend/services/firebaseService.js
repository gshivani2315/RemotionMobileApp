import admin from "firebase-admin";

/**
 * Get Firestore database instance
 */
export const db = admin.firestore();

/**
 * Collections — names match your existing Firestore schema.
 * Users (capital U) is the patient collection used by the web app.
 * app_progress is a subcollection under Users/{uid} owned by this mobile app.
 */
export const Collections = {
  USERS: "Users",               // Matches existing web app schema (capital U)
  PHYSIOTHERAPISTS: "Physiotherapists",
  PROGRAMS: "Programs",
  EXERCISES: "Exercises",
};

// Subcollection name for mobile-app progress panel data
const APP_PROGRESS_SUB = "app_progress";
const APP_PROGRESS_DOC = "current";

// ─── User helpers ────────────────────────────────────────────────────────────

export async function getUserDoc(userId) {
  try {
    const snap = await db.collection(Collections.USERS).doc(userId).get();
    if (!snap.exists) return null;
    return { id: snap.id, ...snap.data() };
  } catch (error) {
    console.error("Error fetching user document:", error);
    throw error;
  }
}

export async function setUserDoc(userId, data, merge = true) {
  try {
    await db.collection(Collections.USERS).doc(userId).set(data, { merge });
    return true;
  } catch (error) {
    console.error("Error setting user document:", error);
    throw error;
  }
}

// ─── Progress helpers ─────────────────────────────────────────────────────────
// Progress panel data lives at:
//   Users/{userId}/app_progress/current
// This keeps it inside the existing Users/{patientId}/{subcollection=**} rules.

export async function getProgressDoc(userId) {
  try {
    const ref = db
      .collection(Collections.USERS)
      .doc(userId)
      .collection(APP_PROGRESS_SUB)
      .doc(APP_PROGRESS_DOC);

    const snap = await ref.get();
    if (!snap.exists) return null;
    return { id: snap.id, ...snap.data() };
  } catch (error) {
    console.error("Error fetching progress document:", error);
    throw error;
  }
}

export async function updateProgressDoc(userId, data) {
  try {
    const ref = db
      .collection(Collections.USERS)
      .doc(userId)
      .collection(APP_PROGRESS_SUB)
      .doc(APP_PROGRESS_DOC);

    await ref.set(data, { merge: true });
    return true;
  } catch (error) {
    console.error("Error updating progress document:", error);
    throw error;
  }
}

// ─── Physio note helper ───────────────────────────────────────────────────────
// Reads the latest physio note from Users/{userId}/physioNotes if it exists,
// otherwise returns a sensible default.

export async function getLatestPhysioNote(userId) {
  try {
    const snap = await db
      .collection(Collections.USERS)
      .doc(userId)
      .collection("physioNotes")
      .orderBy("date", "desc")
      .limit(1)
      .get();

    if (snap.empty) return null;
    return snap.docs[0].data();
  } catch (error) {
    // physioNotes may not exist yet — silently return null
    console.error("Error fetching latest physio note:", error);
    return null;
  }
}

// ─── Initialize default progress for new user ─────────────────────────────────

export async function initializeUserProgress(userId) {
  const defaultProgress = {
    userId,
    levelUp: {
      currentLevel: 1,
      streak: 0,
      message: "Start your recovery journey",
      achievement: "BEGINNER",
      showLevelUp: false,
    },
    recoveryLevel: {
      level: 1,
      percentage: 0.0,
      xp: { current: 0, max: 1000 },
      stats: { sleepQuality: 0.5, hydration: 0.5, mobility: 0.5 },
    },
    streak: {
      days: 0,
      isActive: false,
      lastActivityDate: null,
    },
    timeline: [
      { label: "STARTED",      icon: "eco",     completed: true,  current: true  },
      { label: "WEEK 1",       icon: "fire",    completed: false, current: false },
      { label: "FIRST GEM",    icon: "diamond", completed: false, current: false },
      { label: "RISING STAR",  icon: "star",    completed: false, current: false },
      { label: "PRO",          icon: "lock",    completed: false, current: false },
    ],
    bodyMap: {
      zones: [
        { area: "shoulders", status: "rest", intensity: 0.1 },
        { area: "torso",     status: "rest", intensity: 0.1 },
        { area: "legs",      status: "rest", intensity: 0.1 },
      ],
    },
    movementQuality: {
      flexibility: { value: 50, label: "FLEXIBILITY" },
      strength:    { value: 50, label: "STRENGTH"    },
      endurance:   { value: 50, label: "ENDURANCE"   },
      balance:     { value: 50, label: "BALANCE"     },
    },
    achievements: {
      total: 12,
      unlocked: 1,
      progress: 0.08,
      badges: [
        { id: "first_login",          name: "First Login",          icon: "eco",           unlocked: true  },
        { id: "consistency_diamond",  name: "Consistency Diamond",  icon: "diamond",       unlocked: false },
        { id: "recovery_star",        name: "Recovery Star",        icon: "star",          unlocked: false },
        { id: "balance_badge",        name: "Balance Badge",        icon: "track_changes", unlocked: false },
      ],
    },
    physioNote: {
      message: "Welcome to your recovery journey! Complete your first session to get personalised feedback.",
      author: "ReMotion Team",
      date: new Date().toISOString(),
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  try {
    await updateProgressDoc(userId, defaultProgress);
    return defaultProgress;
  } catch (error) {
    console.error("Error initialising user progress:", error);
    throw error;
  }
}
