import { Router } from 'express';
import authRoutes from './auth.routes';

const router = Router();

// API version prefix
const API_VERSION = '/api/v1';

// Auth routes
router.use(`${API_VERSION}/auth`, authRoutes);

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

export default router;
