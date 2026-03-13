import { getUserDoc, setUserDoc } from "../services/firebaseService.js";

export const getProfile = async (req, res) => {
  try {
    // req.user is available because of the middleware
    const { uid, email } = req.user;
    
    // Fetch user data from Firestore
    let userData = await getUserDoc(uid);
    
    // If user doesn't exist in Firestore, create a basic profile
    if (!userData) {
      userData = {
        uid,
        email,
        displayName: email.split('@')[0], // Use email prefix as default name
        createdAt: new Date().toISOString(),
      };
      await setUserDoc(uid, userData);
    }
    
    res.status(200).json({
      message: "Data fetched from protected route",
      user: userData,
    });
  } catch (error) {
    console.error("Error in getProfile:", error);
    res.status(500).json({ error: error.message });
  }
};