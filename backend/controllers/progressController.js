import admin from "firebase-admin";
const db = admin.firestore();

// ---------------------------------------------------------------------------
// GET /api/progress
// ---------------------------------------------------------------------------
export const getProgress = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    // 1. Fetch the LATEST progress document from the subcollection
    const progressSnap = await db.collection("Users")
      .doc(userId)
      .collection("app_progress")
      .orderBy("updatedAt", "desc")
      .limit(1)
      .get();

    let progressData;

    if (progressSnap.empty) {
      progressData = {
        streak: { days: 0, isActive: false },
        recoveryLevel: { level: 1, percentage: 0, xp: { current: 0, max: 1000 }, stats: { sleepQuality: 0.5, hydration: 0.5, mobility: 0.5 } },
        movementQuality: { flexibility: { value: 0 }, strength: { value: 0 }, endurance: { value: 0 }, balance: { value: 0 } },
        // CHANGE THIS LINE: Provide default zones so Flutter has something to color
        bodyMap: { 
          zones: [
            { area: "shoulders", status: "good", intensity: 0.5 },
            { area: "torso", status: "focus", intensity: 0.8 },
            { area: "legs", status: "rest", intensity: 0.2 }
          ] 
        },
        achievements: { unlocked: 0, total: 10, progress: 0, badges: [] },
        timeline: [
          { label: "STARTED", icon: "eco", completed: true, current: true },
          { label: "WEEK 1", icon: "fire", completed: false, current: false }
        ],
        physioNote: { message: "Welcome to ReMotion!", author: "AI Guide", date: new Date().toISOString() },
        levelUp: { showLevelUp: false }
      };
    } else {
      progressData = progressSnap.docs[0].data();
    }

    // 2. Map the data directly to the Flutter model requirements
    const response = {
      streak: {
        days: progressData.streak?.days ?? 0,
        isActive: progressData.streak?.isActive ?? false,
        lastActivityDate: progressData.streak?.lastActivityDate ?? null,
      },
      recoveryLevel: {
        level: progressData.recoveryLevel?.level ?? 1,
        percentage: progressData.recoveryLevel?.percentage ?? 0,
        stats: {
          sleepQuality: progressData.recoveryLevel?.stats?.sleepQuality ?? 0.5,
          hydration: progressData.recoveryLevel?.stats?.hydration ?? 0.5,
          mobility: progressData.recoveryLevel?.stats?.mobility ?? 0.5,
        },
        xp: {
          current: progressData.recoveryLevel?.xp?.current ?? 0,
          max: progressData.recoveryLevel?.xp?.max ?? 1000,
          // Flutter expects 'progress' field for the XP bar
          progress: progressData.recoveryLevel?.percentage ?? 0, 
        },
      },
      movementQuality: {
        flexibility: {
          label: "FLEXIBILITY",
          value: progressData.movementQuality?.flexibility?.value ?? 0,
          percentage: (progressData.movementQuality?.flexibility?.value ?? 0) / 100,
        },
        strength: {
          label: "STRENGTH",
          value: progressData.movementQuality?.strength?.value ?? 0,
          percentage: (progressData.movementQuality?.strength?.value ?? 0) / 100,
        },
        endurance: {
          label: "ENDURANCE",
          value: progressData.movementQuality?.endurance?.value ?? 0,
          percentage: (progressData.movementQuality?.endurance?.value ?? 0) / 100,
        },
        balance: {
          label: "BALANCE",
          value: progressData.movementQuality?.balance?.value ?? 0,
          percentage: (progressData.movementQuality?.balance?.value ?? 0) / 100,
        },
      },
      bodyMap: {
        zones: progressData.bodyMap?.zones ?? []
      },
      achievements: {
        unlocked: progressData.achievements?.unlocked ?? 0,
        total: progressData.achievements?.total ?? 0,
        progress: progressData.achievements?.progress ?? 0,
        badges: progressData.achievements?.badges ?? []
      },
      physioNote: {
        author: progressData.physioNote?.author ?? "Physio",
        date: progressData.physioNote?.date ?? "",
        message: progressData.physioNote?.message ?? "Keep going!",
      },
      timeline: progressData.timeline ?? [],
      levelUp: {
        showLevelUp: progressData.levelUp?.showLevelUp ?? false,
        currentLevel: progressData.levelUp?.currentLevel ?? 1,
        streak: progressData.streak?.days ?? 0,
        message: progressData.levelUp?.message ?? "",
        achievement: progressData.levelUp?.achievement ?? "",
      },
    };

    return res.status(200).json(response);
  } catch (error) {
    console.error("getProgress error:", error);
    return res.status(500).json({ error: "Failed to fetch progress data" });
  }
};

// ---------------------------------------------------------------------------
// POST /api/progress/level-up-seen
// ---------------------------------------------------------------------------
export const markLevelUpSeen = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    // We must find the LATEST document to turn off the flag
    const latestSnap = await db.collection("Users")
      .doc(userId)
      .collection("app_progress")
      .orderBy("updatedAt", "desc")
      .limit(1)
      .get();

    if (!latestSnap.empty) {
      await latestSnap.docs[0].ref.update({
        "levelUp.showLevelUp": false,
        "updatedAt": admin.firestore.FieldValue.serverTimestamp()
      });
    }

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error("markLevelUpSeen error:", error);
    return res.status(500).json({ error: "Failed to update level-up status" });
  }
};

// ---------------------------------------------------------------------------
// POST /api/progress/reset
// ---------------------------------------------------------------------------
export const resetProgress = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    await initializeUserProgress(userId);
    return res.status(200).json({ success: true, message: "Progress reset" });
  } catch (error) {
    console.error("resetProgress error:", error);
    return res.status(500).json({ error: "Failed to reset progress" });
  }
};

// ---------------------------------------------------------------------------
// PUT /api/progress/update
// ---------------------------------------------------------------------------
export const updateProgress = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    const updates = req.body;
    if (!updates || Object.keys(updates).length === 0) {
      return res.status(400).json({ error: "No update fields provided" });
    }

    await updateProgressDoc(userId, updates);
    return res.status(200).json({ success: true });
  } catch (error) {
    console.error("updateProgress error:", error);
    return res.status(500).json({ error: "Failed to update progress" });
  }
};