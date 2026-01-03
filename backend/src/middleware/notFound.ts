import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';

export const notFound = (req: Request, res: Response): Response => {
  return res.status(StatusCodes.NOT_FOUND).json({
    success: false,
    message: `Route ${req.method} ${req.originalUrl} not found`,
    error: {
      code: 'NOT_FOUND',
    },
  });
};

export default notFound;
