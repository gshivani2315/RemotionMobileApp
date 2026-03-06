export const getProfile = async (req, res) => {
  try {
    // req.user is available because of the middleware
    const { uid, email } = req.user;
    
    // Example: Return user data (In reality, you'd fetch from Supabase here)
    res.status(200).json({
      message: "Data fetched from protected route",
      uid: uid,
      email: email,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};