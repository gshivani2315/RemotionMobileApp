import { Router } from "express";
import { getAssignedExercises } from "../controllers/patientController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const patientRouter = Router();

// GET /api/patients/exercises/assigned
patientRouter.get("/exercises/assigned", verifyToken, getAssignedExercises);

export default patientRouter;