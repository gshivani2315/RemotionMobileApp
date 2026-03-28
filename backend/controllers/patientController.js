import { db } from "../services/firebaseService.js";

export const getAssignedExercises = async (req, res) => {
  try {
    const uid = req.user.uid; // From verifyToken middleware

    // 1. Fetch program configurations from the user's sub-collection
    const configSnap = await db.collection("Users").doc(uid).collection("program_configs").get();

    if (configSnap.empty) {
      return res.status(200).json({
        status: "success",
        data: { exercises: [], count: 0, message: "No programs assigned." },
      });
    }

    // 2. Aggregate Exercise IDs and Overrides
    let allExerciseIds = [];
    let masterOverrides = {};

    configSnap.docs.forEach(doc => {
      const configData = doc.data();
      const overrides = configData.overrides || {};
      const ids = Object.keys(overrides); 
      
      allExerciseIds = [...allExerciseIds, ...ids];
      ids.forEach(id => {
        masterOverrides[id] = { ...overrides[id], programId: doc.id };
      });
    });

    const uniqueExerciseIds = [...new Set(allExerciseIds)];
    if (uniqueExerciseIds.length === 0) {
      return res.status(200).json({ status: "success", data: { exercises: [], count: 0 } });
    }

    // 3. Fetch Master details (Names, Videos, etc.)
    const exercisesSnap = await db.collection("Exercises")
      .where("__name__", "in", uniqueExerciseIds)
      .get();

    // 4. Fetch historical progress to see if they've ever done it
    const progressSnap = await db.collection("Users").doc(uid).collection("daily_progress").get();
    const completedIds = progressSnap.docs.map(d => d.data().exerciseId);

    // 5. Merge logic for Flutter
    const exercises = exercisesSnap.docs.map(doc => {
      const masterData = doc.data();
      const override = masterOverrides[doc.id] || {};

      return {
        exerciseId: doc.id,
        name: masterData.name || "Unknown Exercise",
        sets: override.customSets || masterData.defaultSets || 3,
        reps: override.customReps || masterData.defaultReps || 10,
        instruction: masterData.instructions || "Follow the video carefully.",
        hasEverCompleted: completedIds.includes(doc.id),
      };
    });

    res.status(200).json({
      status: "success",
      data: { exercises, count: exercises.length }
    });

  } catch (error) {
    console.error("Error in getAssignedExercises:", error);
    res.status(500).json({ error: "Failed to load assigned exercises" });
  }
};