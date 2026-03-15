import express from "express";

import { getDashboardStats } from "../controllers/dashboardController.js";

const dashboardRouter = express.Router();

// GET /api/dashboard/stats
dashboardRouter.get("/stats", getDashboardStats);

export default dashboardRouter;