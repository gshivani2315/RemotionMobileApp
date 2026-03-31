import { db } from "../services/firebaseService.js";

export const getDashboardStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // 1. Fetch User Data (Parallel to progress query)
    const userDataSnap = await db.collection("Users").doc(userId).get();
    const userData = userDataSnap.exists ? userDataSnap.data() : null;

    // 2. Fetch the LATEST progress document (Matches getProgress logic)
    const progressSnap = await db.collection("Users")
      .doc(userId)
      .collection("app_progress")
      .orderBy("updatedAt", "desc")
      .limit(1)
      .get();

    // Default progress data if none exists
    let progressData = progressSnap.empty ? null : progressSnap.docs[0].data();

    // 3. Resolve Physiotherapist Details
    let physioName = "Not Assigned";
    // This is the ID string (e.g., "physio_123")
    const therapistId = userData?.physiotherapist_assigned || null;
    
    if (therapistId) {
      // Note: Ensure your collection name is "Physiotherapists" (plural/capitalized) as per your DB
      const tDoc = await db.collection("Physiotherapists").doc(therapistId).get();
      if (tDoc.exists) {
        const tData = tDoc.data();
        physioName = tData.name || tData.displayName || "Physio";
      }
    }

    // 4. Map the response
    const stats = {
      userName: userData?.name || "User",
      physioName: physioName,
      
      // CRITICAL FIX: Send the actual ID back so Flutter can open the chat
      physiotherapist_assigned: therapistId, 
      
      // Safe navigation for progress fields
      recoveryProgress: progressData?.recoveryLevel?.percentage || 0,
      streak: progressData?.levelUp?.streak || progressData?.streak?.days || 0,
      currentLevel: progressData?.recoveryLevel?.level || 1,
      nextSession: "Check your schedule",
    };

    res.json({ 
      success: true, 
      data: stats 
    });

  } catch (error) {
    console.error("Dashboard Stats Error:", error);
    res.status(500).json({ 
      success: false, 
      error: "Internal Server Error",
      message: error.message 
    });
  }
};