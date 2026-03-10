import express from "express";
// verifyToken is NOT imported here — app.js already applies it
// to the entire /api/dashboard prefix before requests reach this router.
// Adding it again here would verify the token twice unnecessarily.

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