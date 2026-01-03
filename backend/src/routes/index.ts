import { Router } from 'express';
import authRoutes from './auth.routes';
import restaurantRoutes from './restaurant.routes';
import menuRoutes from './menu.routes';
import uploadRoutes from './upload.routes';

const router = Router();

// API version prefix
const API_VERSION = '/api/v1';

// Auth routes
router.use(`${API_VERSION}/auth`, authRoutes);

// Restaurant routes
router.use(`${API_VERSION}/restaurants`, restaurantRoutes);

// Menu routes (for restaurant owners)
router.use(`${API_VERSION}/menu`, menuRoutes);

// Upload routes
router.use(`${API_VERSION}/upload`, uploadRoutes);

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

export default router;
