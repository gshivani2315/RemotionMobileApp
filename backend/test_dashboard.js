import admin from 'firebase-admin';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const serviceAccount = require('./config/services.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function simulate() {
  const users = await db.collection('Users').get();
  for (const user of users.docs) {
    if (user.data().name === 'Sumoo') {
      const therapistId = user.data().assignedTherapist;
      console.log(`User ${user.id} (${user.data().name}) has assignedTherapist: ${therapistId || 'NONE'}`);
      if (therapistId) {
        const tDoc = await db.collection('Physiotherapists').doc(therapistId).get();
        if (tDoc.exists) {
          console.log(`  -> Physio resolved to: ${tDoc.data().name || tDoc.data().displayName}`);
        } else {
          console.log(`  -> Physio document NOT FOUND for ID ${therapistId}`);
        }
      }
    }
  }
}

simulate().then(() => process.exit(0)).catch(console.error);
