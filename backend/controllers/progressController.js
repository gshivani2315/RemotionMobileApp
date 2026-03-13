import {
  getProgressDoc,
  updateProgressDoc,
  initializeUserProgress,
  getUserDoc,
} from "../services/firebaseService.js";

// ---------------------------------------------------------------------------
// GET /api/progress
// Merges real user data (streak, adherence) with app_progress/current doc
// ---------------------------------------------------------------------------
export const getProgress = async (req, res) => {
  try {
    const userId = req.user?.uid;
    if (!userId) return res.status(401).json({ error: "Unauthorized" });

    // Fetch both documents in parallel
    let [progressData, userData] = await Promise.all([
      getProgressDoc(userId),
      getUserDoc(userId),
    ]);

    // First-time user — initialise their progress document
    if (!progressData) {
      progressData = await initializeUserProgress(userId);
    }

    // Pull real values from the user document
    const realStreak = userData?.streak ?? userData?.adherence_metrics?.streak ?? 0;
    const sessionsCompleted =
      userData?.adherenceMetrics?.sessionsCompleted ??
      userData?.adherence_metrics?.sessions_completed ??
      0;
    const adherenceScore = userData?.adherenceScore ?? 0;

    // Derive XP from sessions (each session = 50 XP, cap at max)
    const xpMax = progressData.recoveryLevel?.xp?.max ?? 1000;
    const xpCurrent = Math.min(sessionsCompleted * 50, xpMax);

    // Derive recovery level from XP (level up every 1000 XP)
    const recoveryLevel = Math.max(1, Math.floor(xpCurrent / xpMax) + 1);

    // Derive movement quality from adherence score (scale 0-100)
    const qualityScore = Math.round(adherenceScore);

    const response = {
      streak: {
        days: realStreak,
        isActive: realStreak > 0,
        lastActivityDate:
          userData?.adherence_metrics?.last_active?.toDate?.()?.toISOString() ??
          userData?.lastActive ??
          null,
      },
      recoveryLevel: {
        level: progressData.recoveryLevel?.level ?? recoveryLevel,
        percentage: (xpCurrent / xpMax),
        stats: {
          sleepQuality: progressData.recoveryLevel?.stats?.sleepQuality ?? 0.5,
          hydration: progressData.recoveryLevel?.stats?.hydration ?? 0.5,
          mobility: progressData.recoveryLevel?.stats?.mobility ?? 0.5,
        },
        xp: {
          current: progressData.recoveryLevel?.xp?.current ?? xpCurrent,
          max: xpMax,
          progress: (progressData.recoveryLevel?.xp?.current ?? xpCurrent) / xpMax,
        },
      },
      movementQuality: {
        flexibility: {
          label: "FLEXIBILITY",
          value: progressData.movementQuality?.flexibility?.value ?? qualityScore,
          percentage: (progressData.movementQuality?.flexibility?.value ?? qualityScore) / 100,
        },
        strength: {
          label: "STRENGTH",
          value: progressData.movementQuality?.strength?.value ?? qualityScore,
          percentage: (progressData.movementQuality?.strength?.value ?? qualityScore) / 100,
        },
        endurance: {
          label: "ENDURANCE",
          value: progressData.movementQuality?.endurance?.value ?? qualityScore,
          percentage: (progressData.movementQuality?.endurance?.value ?? qualityScore) / 100,
        },
        balance: {
          label: "BALANCE",
          value: progressData.movementQuality?.balance?.value ?? qualityScore,
          percentage: (progressData.movementQuality?.balance?.value ?? qualityScore) / 100,
        },
      },
      bodyMap: {
        zones: (progressData.bodyMap?.zones ?? []).map((zone) => ({
          area: zone.area,
          status: zone.status,
          intensity: zone.intensity ?? 0,
        })),
      },
      achievements: {
        unlocked: progressData.achievements?.unlocked ?? 0,
        total: progressData.achievements?.total ?? 0,
        progress: progressData.achievements?.progress ?? 0,
        badges: (progressData.achievements?.badges ?? []).map((badge) => ({
          id: badge.id,
          icon: badge.icon,
          name: badge.name,
          unlocked: badge.unlocked ?? false,
        })),
      },
      physioNote: {
        author: progressData.physioNote?.author ?? "",
        date: progressData.physioNote?.date ?? "",
        message: progressData.physioNote?.message ?? "",
      },
      timeline: (progressData.timeline ?? []).map((item) => ({
        label: item.label,
        icon: item.icon,
        completed: item.completed ?? false,
        current: item.current ?? false,
      })),
      levelUp: {
        showLevelUp: progressData.levelUp?.showLevelUp ?? false,
        currentLevel: progressData.levelUp?.currentLevel ?? 1,
        streak: realStreak,
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

    await updateProgressDoc(userId, { "levelUp.showLevelUp": false });
    return res.status(200).json({ success: true });
  } catch (error) {
    console.error("markLevelUpSeen error:", error);
    return res.status(500).json({ error: "Failed to update level-up status" });
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