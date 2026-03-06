import admin from "firebase-admin";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
const serviceAccount = require("../config/services.json"); // Path to your file

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Access denied. No token provided." });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken; // This contains uid, email, etc.
    next();
  } catch (error) {
    res.status(403).json({ error: "Invalid or expired token." });
  }
};