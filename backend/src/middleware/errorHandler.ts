import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import mongoose from 'mongoose';
import { AppError } from '../utils/errors';
import { logger } from '../utils/logger';
import { config } from '../config';

interface ErrorResponse {
  success: false;
  message: string;
  error: {
    code: string;
    details?: unknown;
    stack?: string;
  };
}

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): Response => {
  let statusCode = StatusCodes.INTERNAL_SERVER_ERROR;
  let code = 'SERVER_ERROR';
  let message = 'Internal server error';
  let details: unknown = undefined;

  // Log the error
  logger.error(`Error: ${err.message}`, {
    stack: err.stack,
    name: err.name,
  });

  // Handle known errors
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    code = err.code;
    message = err.message;
    details = err.details;
  }
  // Handle Mongoose validation errors
  else if (err instanceof mongoose.Error.ValidationError) {
    statusCode = StatusCodes.BAD_REQUEST;
    code = 'VALIDATION_ERROR';
    message = 'Validation failed';
    details = Object.values(err.errors).map((e) => ({
      field: e.path,
      message: e.message,
    }));
  }
  // Handle Mongoose CastError (invalid ObjectId)
  else if (err instanceof mongoose.Error.CastError) {
    statusCode = StatusCodes.BAD_REQUEST;
    code = 'INVALID_ID';
    message = `Invalid ${err.path}: ${err.value}`;
  }
  // Handle duplicate key errors
  else if ((err as { code?: number }).code === 11000) {
    statusCode = StatusCodes.CONFLICT;
    code = 'DUPLICATE_KEY';
    const keyValue = (err as { keyValue?: Record<string, unknown> }).keyValue;
    const field = keyValue ? Object.keys(keyValue)[0] : 'field';
    message = `${field} already exists`;
  }
  // Handle JWT errors
  else if (err.name === 'JsonWebTokenError') {
    statusCode = StatusCodes.UNAUTHORIZED;
    code = 'INVALID_TOKEN';
    message = 'Invalid token';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = StatusCodes.UNAUTHORIZED;
    code = 'TOKEN_EXPIRED';
    message = 'Token expired';
  }

  const response: ErrorResponse = {
    success: false,
    message,
    error: {
      code,
      details,
    },
  };

  // Include stack trace in development
  if (config.nodeEnv === 'development') {
    response.error.stack = err.stack;
  }

  return res.status(statusCode).json(response);
};

export default errorHandler;
