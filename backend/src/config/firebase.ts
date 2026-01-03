import admin from 'firebase-admin';
import { config } from './index';
import { logger } from '../utils/logger';

let firebaseApp: admin.app.App | null = null;

export const initializeFirebase = (): admin.app.App | null => {
  if (!config.firebase.projectId || !config.firebase.privateKey || !config.firebase.clientEmail) {
    logger.warn('Firebase credentials not configured. Push notifications will not work.');
    return null;
  }

  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: config.firebase.projectId,
        privateKey: config.firebase.privateKey,
        clientEmail: config.firebase.clientEmail,
      }),
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
