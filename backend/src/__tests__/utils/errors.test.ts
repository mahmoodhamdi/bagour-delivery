import { StatusCodes } from 'http-status-codes';
import {
  AppError,
  NotFoundError,
  BadRequestError,
  UnauthorizedError,
  ForbiddenError,
  ValidationError,
  ConflictError,
  TooManyRequestsError,
  ServiceUnavailableError,
} from '../../utils/errors';

describe('Error Classes', () => {
  describe('AppError', () => {
    it('should create an error with default values', () => {
      const error = new AppError('Test error');

      expect(error.message).toBe('Test error');
      expect(error.statusCode).toBe(StatusCodes.INTERNAL_SERVER_ERROR);
      expect(error.isOperational).toBe(true);
      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(AppError);
    });

    it('should create an error with custom status code', () => {
      const error = new AppError('Test error', StatusCodes.BAD_REQUEST);

      expect(error.statusCode).toBe(StatusCodes.BAD_REQUEST);
    });

    it('should handle old pattern (message, statusCode, code, details)', () => {
      const error = new AppError('Test error', 400, 'CUSTOM_CODE', { field: 'test' });

      expect(error.code).toBe('CUSTOM_CODE');
      expect(error.details).toEqual({ field: 'test' });
    });

    it('should handle new pattern (message, statusCode, isOperational, code, details)', () => {
      const error = new AppError('Test error', 400, false, 'CUSTOM_CODE', { field: 'test' });

      expect(error.isOperational).toBe(false);
      expect(error.code).toBe('CUSTOM_CODE');
      expect(error.details).toEqual({ field: 'test' });
    });
  });

  describe('NotFoundError', () => {
    it('should create a 404 error', () => {
      const error = new NotFoundError('User not found');

      expect(error.message).toBe('User not found');
      expect(error.statusCode).toBe(StatusCodes.NOT_FOUND);
      expect(error.code).toBe('NOT_FOUND');
    });

    it('should use default message', () => {
      const error = new NotFoundError();

      expect(error.message).toBe('Resource not found');
    });

    it('should include details', () => {
      const error = new NotFoundError('User not found', { userId: '123' });

      expect(error.details).toEqual({ userId: '123' });
    });
  });

  describe('BadRequestError', () => {
    it('should create a 400 error', () => {
      const error = new BadRequestError('Invalid input');

      expect(error.message).toBe('Invalid input');
      expect(error.statusCode).toBe(StatusCodes.BAD_REQUEST);
      expect(error.code).toBe('BAD_REQUEST');
    });

    it('should use default message', () => {
      const error = new BadRequestError();

      expect(error.message).toBe('Bad request');
    });
  });

  describe('UnauthorizedError', () => {
    it('should create a 401 error', () => {
      const error = new UnauthorizedError('Invalid token');

      expect(error.message).toBe('Invalid token');
      expect(error.statusCode).toBe(StatusCodes.UNAUTHORIZED);
      expect(error.code).toBe('UNAUTHORIZED');
    });

    it('should use default message', () => {
      const error = new UnauthorizedError();

      expect(error.message).toBe('Unauthorized');
    });
  });

  describe('ForbiddenError', () => {
    it('should create a 403 error', () => {
      const error = new ForbiddenError('Access denied');

      expect(error.message).toBe('Access denied');
      expect(error.statusCode).toBe(StatusCodes.FORBIDDEN);
      expect(error.code).toBe('FORBIDDEN');
    });

    it('should use default message', () => {
      const error = new ForbiddenError();

      expect(error.message).toBe('Forbidden');
    });
  });

  describe('ValidationError', () => {
    it('should create a 400 validation error', () => {
      const error = new ValidationError('Email is invalid');

      expect(error.message).toBe('Email is invalid');
      expect(error.statusCode).toBe(StatusCodes.BAD_REQUEST);
      expect(error.code).toBe('VALIDATION_ERROR');
    });

    it('should include validation details', () => {
      const validationDetails = {
        email: 'Invalid email format',
        password: 'Password too short',
      };
      const error = new ValidationError('Validation failed', validationDetails);

      expect(error.details).toEqual(validationDetails);
    });
  });

  describe('ConflictError', () => {
    it('should create a 409 error', () => {
      const error = new ConflictError('Email already exists');

      expect(error.message).toBe('Email already exists');
      expect(error.statusCode).toBe(StatusCodes.CONFLICT);
      expect(error.code).toBe('CONFLICT');
    });

    it('should use default message', () => {
      const error = new ConflictError();

      expect(error.message).toBe('Resource already exists');
    });
  });

  describe('TooManyRequestsError', () => {
    it('should create a 429 error', () => {
      const error = new TooManyRequestsError('Rate limit exceeded');

      expect(error.message).toBe('Rate limit exceeded');
      expect(error.statusCode).toBe(StatusCodes.TOO_MANY_REQUESTS);
      expect(error.code).toBe('TOO_MANY_REQUESTS');
    });
  });

  describe('ServiceUnavailableError', () => {
    it('should create a 503 error', () => {
      const error = new ServiceUnavailableError('Database connection failed');

      expect(error.message).toBe('Database connection failed');
      expect(error.statusCode).toBe(StatusCodes.SERVICE_UNAVAILABLE);
      expect(error.code).toBe('SERVICE_UNAVAILABLE');
    });
  });

  describe('Error inheritance', () => {
    it('should be catchable as Error', () => {
      const throwError = () => {
        throw new NotFoundError('Test');
      };

      expect(throwError).toThrow(Error);
    });

    it('should be catchable as AppError', () => {
      const throwError = () => {
        throw new NotFoundError('Test');
      };

      expect(throwError).toThrow(AppError);
    });

    it('should be catchable as specific error type', () => {
      const throwError = () => {
        throw new NotFoundError('Test');
      };

      expect(throwError).toThrow(NotFoundError);
    });
  });
});
