import express from 'express';
import { verifyToken } from './middleware/authMiddleware.js';
import { getProfile } from './controllers/userController.js';

const app = express();
app.use(express.json());

// Public Route
app.get('/', (req, res) => res.send('ReMotion API is running.'));

// Protected Routes - Use middleware here
app.get('/api/profile', verifyToken, getProfile);

app.listen(3000, () => {
    console.log("Backend running on http://localhost:3000");
})