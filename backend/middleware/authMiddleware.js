import admin from "firebase-admin";
import { createRequire } from "module";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envFile = process.env.NODE_ENV === "production"
  ? ".env.production.local"
  : ".env.development.local";
dotenv.config({ path: path.resolve(__dirname, "..", envFile) });

const require = createRequire(import.meta.url);

let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
} else if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
  serviceAccount = require(path.resolve(__dirname, "..", process.env.FIREBASE_SERVICE_ACCOUNT_PATH));
} else {
  throw new Error("No Firebase service account configured. Set FIREBASE_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_PATH in your env file.");
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Access denied. No token provided." });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);

    const nowSeconds = Math.floor(Date.now() / 1000);
    if (nowSeconds - decodedToken.iat > 3600) {
      return res.status(403).json({ error: "Token too old. Please re-authenticate." });
    }

    req.user = decodedToken;
    next();
  } catch (error) {
    console.error("Token verification failed:", error.code);
    return res.status(403).json({ error: "Invalid or expired token." });
  }
};