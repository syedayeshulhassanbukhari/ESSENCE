const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function initializeFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return admin;
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    throw new Error('FIREBASE_PROJECT_ID is required.');
  }

  const credentialsPath = process.env.FIREBASE_CREDENTIALS_PATH || process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialsPath) {
    throw new Error('FIREBASE_CREDENTIALS_PATH or GOOGLE_APPLICATION_CREDENTIALS is required.');
  }

  const resolvedCredentialsPath = path.isAbsolute(credentialsPath)
    ? credentialsPath
    : path.resolve(process.cwd(), credentialsPath);

  if (!fs.existsSync(resolvedCredentialsPath)) {
    throw new Error(`Firebase credentials file not found at ${resolvedCredentialsPath}`);
  }

  const serviceAccount = require(resolvedCredentialsPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId,
  });

  return admin;
}

function getFirestore() {
  initializeFirebaseAdmin();
  return admin.firestore();
}

async function verifyFirebaseIdToken(idToken) {
  initializeFirebaseAdmin();
  return admin.auth().verifyIdToken(idToken, true);
}

module.exports = {
  admin,
  initializeFirebaseAdmin,
  getFirestore,
  verifyFirebaseIdToken,
};
