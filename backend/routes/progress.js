import express from "express";
import {
  getProgress,
  markLevelUpSeen,
  updateProgress,
  resetProgress,
} from "../controllers/progressController.js";

const progressRouter = express.Router();

// GET /api/progress
// Returns complete progress data for the user from Firestore
progressRouter.get("/", getProgress);

// POST /api/progress/level-up-seen
// Mark the level up notification as seen
progressRouter.post("/level-up-seen", markLevelUpSeen);

// PUT /api/progress/update
// Update specific progress fields
progressRouter.put("/update", updateProgress);

// POST /api/progress/reset
// Reset progress to default values (useful for testing/development)
progressRouter.post("/reset", resetProgress);

export default progressRouter;
