import { getProgressDoc } from "../services/firebaseService.js";

/**
 * GET /api/dashboard/stats
 * Fetch basic stats for dashboard display
 */
export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // Get progress data from Firestore
    const progressData = await getProgressDoc(userId);

    if (!progressData) {
      return res.status(404).json({
        success: false,
        error: "Progress data not found. Please initialize your profile.",
      });
    }

    // Extract relevant stats for dashboard
    const stats = {
      userId,
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
