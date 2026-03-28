import { getProgressDoc, getUserDoc, db, Collections } from "../services/firebaseService.js";

/**
 * GET /api/dashboard/stats
 * Fetch basic stats for dashboard display
 */
export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // Get progress data and user data from Firestore in parallel
    const [progressData, userData] = await Promise.all([
      getProgressDoc(userId),
      getUserDoc(userId)
    ]);

    if (!progressData) {
      return res.status(404).json({
        success: false,
        error: "Progress data not found. Please initialize your profile.",
      });
    }

    // Determine User Name (fallback to email or 'User')
    const userName = userData?.name || userData?.displayName || userData?.email || "User";

    // Determine Physiotherapist Name
    let physioName = "Not Assigned";
    // const therapistId = userData?.assignedTherapist;
    const therapistId = userData?.physiotherapist_assigned;
    
    if (therapistId) {
      try {
        const therapistDoc = await db.collection(Collections.PHYSIOTHERAPISTS).doc(therapistId).get();
        if (therapistDoc.exists) {
          const tData = therapistDoc.data();
          physioName = tData.name || tData.displayName || tData.email || "Not Assigned";
        }
      } catch (err) {
        console.error("Error fetching physiotherapist details:", err);
      }
    }

    // Extract relevant stats for dashboard
    const stats = {
      userId,
      userName,
      physioName,
      physiotherapist_assigned: therapistId,
      streak: progressData.streak?.days || 0,
      nextSession: "Check your schedule", // This could be pulled from a sessions collection
      recoveryProgress: progressData.recoveryLevel?.percentage || 0,
      currentLevel: progressData.recoveryLevel?.level || 1,
      xpProgress: progressData.recoveryLevel?.xp || { current: 0, max: 1000 },
    };

    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch dashboard stats",
      message: error.message,
    });
  }
};
