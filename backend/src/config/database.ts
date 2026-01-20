import mongoose from 'mongoose';
import { config } from './index';
import { logger } from '../utils/logger';

/**
 * Database health status
 */
export interface DatabaseHealth {
  status: 'connected' | 'disconnected' | 'connecting' | 'unknown';
  host?: string;
  name?: string;
  readyState: number;
}

/**
 * Get current database health status
 */
export const getDatabaseHealth = (): DatabaseHealth => {
  const readyState = mongoose.connection.readyState;
  const statusMap: Record<number, DatabaseHealth['status']> = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnected', // disconnecting
  };

  return {
    status: statusMap[readyState] || 'unknown',
    host: mongoose.connection.host,
    name: mongoose.connection.name,
    readyState,
  };
};

export const connectDatabase = async (): Promise<void> => {
  try {
    const conn = await mongoose.connect(config.mongoUri);
    logger.info(`MongoDB Connected: ${conn.connection.host}`);

    mongoose.connection.on('error', (err) => {
      logger.error(`MongoDB connection error: ${err}`);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });

    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('MongoDB connection closed through app termination');
      process.exit(0);
    });
  } catch (error) {
    logger.error(`Error connecting to MongoDB: ${error}`);
    process.exit(1);
  }
};

export default connectDatabase;
