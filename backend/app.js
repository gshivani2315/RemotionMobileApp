import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envFile = process.env.NODE_ENV === "production"
  ? ".env.production.local"
  : ".env.development.local";
dotenv.config({ path: path.resolve(__dirname, envFile) });

import express from "express";
import cors from "cors";
import helmet from "helmet";
import { apiLimiter } from "./middleware/rateLimiter.js";
import { verifyToken } from "./middleware/authMiddleware.js";
import { getProfile } from "./controllers/userController.js";
import dashboardRouter from "./routes/dashboard.js";

const app = express();
const PORT = process.env.PORT;

console.log(`Running in ${process.env.NODE_ENV} mode`);

app.use(helmet());

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(",")
  : [];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin && process.env.NODE_ENV !== "production") {
        return callback(null, true);
      }
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      callback(new Error("Not allowed by CORS"));
    },
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Authorization", "Content-Type"],
  })
);

app.use(express.json({ limit: "10kb" }));
app.use("/api", apiLimiter);

// Public
app.get("/", (req, res) => res.send("ReMotion API is running."));

// Protected
app.get("/api/profile", verifyToken, getProfile);
app.use("/api/dashboard", verifyToken, dashboardRouter);

// 404
app.use((req, res) => {
  res.status(404).json({ error: "Route not found." });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err.message);
  res.status(500).json({ error: "Internal server error." });
});

app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});