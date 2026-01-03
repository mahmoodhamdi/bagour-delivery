import { Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import { IApiResponse } from '../types';

export const sendSuccess = <T>(
  res: Response,
  data?: T,
  message?: string,
  statusCode: number = StatusCodes.OK
): Response => {
  const response: IApiResponse<T> = {
    success: true,
    message,
    data,
  };

  return res.status(statusCode).json(response);
};

export const successResponse = <T>(
  res: Response,
  statusCode: number,
  message: string,
  data?: T
): Response => {
  const response: IApiResponse<T> = {
    success: true,
    message,
    data,
  };

  return res.status(statusCode).json(response);
};

export const sendCreated = <T>(res: Response, data?: T, message?: string): Response => {
  return sendSuccess(res, data, message, StatusCodes.CREATED);
};

export const sendPaginated = <T>(
  res: Response,
  data: T[],
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  },
  message?: string
): Response => {
  const response: IApiResponse<T[]> = {
    success: true,
    message,
    data,
    pagination,
  };

  return res.status(StatusCodes.OK).json(response);
};

export const sendError = (
  res: Response,
  message: string,
  statusCode: number = StatusCodes.BAD_REQUEST,
  errorCode?: string,
  details?: unknown
): Response => {
  const response: IApiResponse = {
    success: false,
    message,
    error: {
      code: errorCode || 'ERROR',
      details,
    },
  };

  return res.status(statusCode).json(response);
};

export const sendNotFound = (res: Response, message: string = 'Resource not found'): Response => {
  return sendError(res, message, StatusCodes.NOT_FOUND, 'NOT_FOUND');
};

export const sendUnauthorized = (res: Response, message: string = 'Unauthorized'): Response => {
  return sendError(res, message, StatusCodes.UNAUTHORIZED, 'UNAUTHORIZED');
};

export const sendForbidden = (res: Response, message: string = 'Forbidden'): Response => {
  return sendError(res, message, StatusCodes.FORBIDDEN, 'FORBIDDEN');
};

export const sendValidationError = (res: Response, errors: unknown): Response => {
  return sendError(res, 'Validation failed', StatusCodes.BAD_REQUEST, 'VALIDATION_ERROR', errors);
};

export const sendServerError = (
  res: Response,
  message: string = 'Internal server error'
): Response => {
  return sendError(res, message, StatusCodes.INTERNAL_SERVER_ERROR, 'SERVER_ERROR');
};

export default {
  sendSuccess,
  sendCreated,
  sendPaginated,
  sendError,
  sendNotFound,
  sendUnauthorized,
  sendForbidden,
  sendValidationError,
  sendServerError,
};
