import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from './config';
import { getDatabaseHealth } from './config/database';
import { errorHandler } from './middleware/errorHandler';
import { notFound } from './middleware/notFound';
import { sanitizeInput } from './middleware/sanitize';
import routes from './routes';
import { setupSwagger } from './config/swagger';

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

  // Input sanitization (NoSQL injection & XSS protection)
  app.use(sanitizeInput);

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
    const dbHealth = getDatabaseHealth();
    const isHealthy = dbHealth.status === 'connected';

    res.status(isHealthy ? 200 : 503).json({
      success: isHealthy,
      message: isHealthy ? 'Server is healthy' : 'Server is degraded',
      data: {
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: config.nodeEnv,
        version: process.env.npm_package_version || '1.0.0',
        memory: {
          used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
          unit: 'MB',
        },
        database: dbHealth,
      },
    });
  });

  // Liveness probe (for kubernetes/docker health checks)
  app.get('/health/live', (_req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  // Readiness probe (checks if app can accept traffic)
  app.get('/health/ready', (_req, res) => {
    const dbHealth = getDatabaseHealth();
    if (dbHealth.status === 'connected') {
      res.status(200).json({ status: 'ready', database: 'connected' });
    } else {
      res.status(503).json({ status: 'not ready', database: dbHealth.status });
    }
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
        docs: '/api-docs',
      },
    });
  });

  // Setup Swagger documentation
  setupSwagger(app);

  // All API routes
  app.use(routes);

  // 404 handler
  app.use(notFound);

  // Error handler
  app.use(errorHandler);

  return app;
};

export default createApp;
