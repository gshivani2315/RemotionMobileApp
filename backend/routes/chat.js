import { Router } from "express";
import { sendMessage, getMessages } from "../controllers/chatController.js";
import { verifyToken } from "../middleware/authMiddleware.js";

const chatRouter = Router();

// Endpoint for sending a message
chatRouter.post("/patient-to-physio/:physioId/message", verifyToken, sendMessage);

// Endpoint for fetching chat history
chatRouter.get("/patient-to-physio/:physioId/messages", verifyToken, getMessages);

export default chatRouter;