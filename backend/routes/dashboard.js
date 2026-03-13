import express from "express";

const dashboardRouter = express.Router();

// GET /api/dashboard/stats
dashboardRouter.get("/stats", (req, res) => {
  const userId = req.user.uid;

  res.json({
    success: true,
    data: {
      userId,
      streak: 7,
      nextSession: "Tomorrow at 10:00 AM",
      recoveryProgress: 0.85,
    },
  });
});

export default dashboardRouter;