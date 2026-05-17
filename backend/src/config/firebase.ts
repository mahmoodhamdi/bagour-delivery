import admin from 'firebase-admin';
import { config } from './index';
import { logger } from '../utils/logger';

let firebaseApp: admin.app.App | null = null;

export const initializeFirebase = (): admin.app.App | null => {
  const { projectId, privateKey, clientEmail } = config.firebase;

  // Detect placeholder credentials (the values shipped in `.env.example`)
  // so we don't spam a startup error on every fresh-clone dev box.
  const hasPlaceholder =
    !projectId ||
    !privateKey ||
    !clientEmail ||
    privateKey.includes('your-firebase-private-key') ||
    !privateKey.includes('BEGIN PRIVATE KEY');

  if (hasPlaceholder) {
    logger.warn('[Firebase] Skipping Admin SDK init — credentials missing or placeholder');
    return null;
  }

  // Reuse the already-initialised app — `auth.service.ts` calls initializeApp
  // at module load when real creds are present, and re-initialising throws.
  if (admin.apps.length) {
    firebaseApp = admin.apps[0] ?? null;
    return firebaseApp;
  }

  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({ projectId, privateKey, clientEmail }),
    });
    logger.info('Firebase initialized successfully');
    return firebaseApp;
  } catch (error) {
    logger.error(`Error initializing Firebase: ${error}`);
    return null;
  }
};

export const getFirebaseApp = (): admin.app.App | null => firebaseApp;

export const getFirebaseMessaging = (): admin.messaging.Messaging | null => {
  if (!firebaseApp) return null;
  return firebaseApp.messaging();
};

export default initializeFirebase;
