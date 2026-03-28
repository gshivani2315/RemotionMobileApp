import {db} from "../services/firebaseService.js";
import admin from "firebase-admin";

// Helper to ensure the ID is always "smallerID_largerID"
const getConversationId = (id1, id2) => {
  const ids = [id1, id2].sort();
  return `${ids[0]}_${ids[1]}`;
};

export const sendMessage = async (req, res) => {
  try {
    const patientUid = req.user.uid; // From verifyToken middleware
    const { physioId } = req.params;
    const { content } = req.body;

    if (!content?.trim()) {
      return res.status(400).json({ error: "Message content is required" });
    }

    const conversationId = getConversationId(patientUid, physioId);
    const convRef = db.collection("conversations").doc(conversationId);
    const messageRef = convRef.collection("messages").doc();

    const batch = db.batch();

    // Update the parent conversation metadata
    batch.set(convRef, {
      participantA: patientUid,
      participantB: physioId,
      lastMessage: content.trim(),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      lastSenderType: "user", // 'user' represents the patient in your schema
      unreadCountPhysio: admin.firestore.FieldValue.increment(1),
    }, { merge: true });

    // Add the specific message to the sub-collection
    batch.set(messageRef, {
      id: messageRef.id,
      content: content.trim(),
      senderId: patientUid,
      senderType: "user",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

    await batch.commit();

    res.status(201).json({
      success: true,
      messageId: messageRef.id,
      conversationId: conversationId
    });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({ error: "Failed to send message" });
  }
};

export const getMessages = async (req, res) => {
  try {
    const patientUid = req.user.uid;
    const { physioId } = req.params;
    const conversationId = getConversationId(patientUid, physioId);

    const snapshot = await db
      .collection("conversations")
      .doc(conversationId)
      .collection("messages")
      .orderBy("timestamp", "asc")
      .limit(50)
      .get();

    const messages = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        // Convert Firestore Timestamp to ISO String for Flutter
        timestamp: data.timestamp?.toDate().toISOString() || new Date().toISOString(),
      };
    });

    res.status(200).json({ messages });
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: "Failed to fetch messages" });
  }
};