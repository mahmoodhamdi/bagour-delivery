import { Router } from 'express';
import authRoutes from './auth.routes';
import restaurantRoutes from './restaurant.routes';
import menuRoutes from './menu.routes';
import uploadRoutes from './upload.routes';
import orderRoutes, {
  restaurantRouter as restaurantOrderRoutes,
  driverRouter as driverOrderRoutes,
  adminRouter as adminOrderRoutes,
} from './order.routes';

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

// Order routes (customer)
router.use(`${API_VERSION}/orders`, orderRoutes);

// Restaurant order routes
router.use(`${API_VERSION}/restaurant`, restaurantOrderRoutes);

// Driver order routes
router.use(`${API_VERSION}/driver`, driverOrderRoutes);

// Admin order routes
router.use(`${API_VERSION}/admin`, adminOrderRoutes);

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

export default router;
