import express from "express";
import {verifyToken} from "../middleware/authMiddleware.js";

const dashboardRouter = express.Router();

// Protected Route: GET /api/dashboard/stats
dashboardRouter.get("/stats", verifyToken, (req, res) => {
  // Use req.user.uid to filter data for this specific user in your DB
  const userId = req.user.uid;

  res.json({
    success: true,
    data: {
      userId: userId,
      streak: 7,
      nextSession: "Tomorrow at 10:00 AM",
      recoveryProgress: 0.85, // 85%
    },
  });
});

export default dashboardRouter;