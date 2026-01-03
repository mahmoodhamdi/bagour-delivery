import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from './config';
import { errorHandler } from './middleware/errorHandler';
import { notFound } from './middleware/notFound';

export const createApp = (): Express => {
  const app = express();

  // Security middleware
  app.use(helmet());

  // CORS
  app.use(
    cors({
      origin: config.corsOrigins,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    })
  );

  // Rate limiting
  const limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.maxRequests,
    message: {
      success: false,
      message: 'Too many requests, please try again later',
      error: { code: 'TOO_MANY_REQUESTS' },
    },
  });
  app.use('/api/', limiter);

  // Body parsing
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Compression
  app.use(compression());

  // Logging
  if (config.nodeEnv === 'development') {
    app.use(morgan('dev'));
  } else {
    app.use(morgan('combined'));
  }

  // Health check
  app.get('/health', (_req, res) => {
    res.status(200).json({
      success: true,
      message: 'Server is healthy',
      data: {
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: config.nodeEnv,
      },
    });
  });

  // API version info
  app.get(`/api/${config.apiVersion}`, (_req, res) => {
    res.status(200).json({
      success: true,
      message: 'Bagour Delivery API',
      data: {
        version: config.apiVersion,
        name: 'Bagour Delivery API',
        description: 'Food delivery platform for Bagour city',
      },
    });
  });

  // Routes will be added here
  // app.use(`/api/${config.apiVersion}/auth`, authRoutes);
  // app.use(`/api/${config.apiVersion}/restaurants`, restaurantRoutes);
  // app.use(`/api/${config.apiVersion}/orders`, orderRoutes);
  // ... more routes

  // 404 handler
  app.use(notFound);

  // Error handler
  app.use(errorHandler);

  return app;
};

export default createApp;
