import http from 'http';
import { createApp } from './app';
import { config } from './config';
import { connectDatabase } from './config/database';
import { configureCloudinary } from './config/cloudinary';
import { initializeFirebase } from './config/firebase';
import { initializeSocket } from './config/socket';
import { validateEnv } from './config/validateEnv';
import { logger } from './utils/logger';

const startServer = async (): Promise<void> => {
  try {
    // Validate environment variables first
    validateEnv();

    // Connect to database
    await connectDatabase();

    // Configure external services
    configureCloudinary();
    initializeFirebase();

    // Create Express app
    const app = createApp();

    // Create HTTP server
    const httpServer = http.createServer(app);

    // Initialize Socket.io
    initializeSocket(httpServer);

    // Start server
    httpServer.listen(config.port, () => {
      logger.info(`🚀 Server running on port ${config.port}`);
      logger.info(`📡 Environment: ${config.nodeEnv}`);
      logger.info(`🔗 API: http://localhost:${config.port}/api/${config.apiVersion}`);
      logger.info(`📚 Docs: http://localhost:${config.port}/api-docs`);
      logger.info(`❤️  Health: http://localhost:${config.port}/health`);
    });

    // Handle graceful shutdown
    const shutdown = async (signal: string): Promise<void> => {
      logger.info(`Received ${signal}. Shutting down gracefully...`);

      httpServer.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
      });

      // Force close after 10 seconds
      setTimeout(() => {
        logger.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    // Handle uncaught exceptions
    process.on('uncaughtException', (error: Error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason: unknown) => {
      logger.error('Unhandled Rejection:', reason);
      process.exit(1);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
