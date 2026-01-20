import { Request, Response, NextFunction } from 'express';

/**
 * Recursively sanitize an object by removing MongoDB operators
 * and potential XSS patterns
 */
function sanitizeObject(obj: unknown): unknown {
  if (obj === null || obj === undefined) {
    return obj;
  }

  if (typeof obj === 'string') {
    // Remove potential XSS patterns (basic sanitization)
    let sanitized = obj
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/javascript:/gi, '')
      .replace(/on\w+\s*=/gi, '');

    return sanitized;
  }

  if (typeof obj !== 'object') {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(sanitizeObject);
  }

  const sanitized: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
    // Remove keys starting with $ (MongoDB operators)
    if (key.startsWith('$')) {
      continue;
    }
    // Remove keys containing dots (MongoDB nested access)
    if (key.includes('.')) {
      continue;
    }
    sanitized[key] = sanitizeObject(value);
  }

  return sanitized;
}

/**
 * Middleware to sanitize request body, query, and params
 * Protects against NoSQL injection and basic XSS attacks
 */
export const sanitizeInput = (req: Request, _res: Response, next: NextFunction): void => {
  if (req.body) {
    req.body = sanitizeObject(req.body);
  }

  if (req.query) {
    req.query = sanitizeObject(req.query) as typeof req.query;
  }

  if (req.params) {
    req.params = sanitizeObject(req.params) as typeof req.params;
  }

  next();
};

/**
 * Sanitize a single string value
 * Use this for individual field sanitization
 */
export const sanitizeString = (str: string): string => {
  if (typeof str !== 'string') {
    return str;
  }

  return str
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+\s*=/gi, '')
    .trim();
};

/**
 * Sanitize MongoDB query to prevent injection
 * Removes dangerous operators from query objects
 */
export const sanitizeMongoQuery = (query: Record<string, unknown>): Record<string, unknown> => {
  const dangerousOperators = [
    '$where',
    '$regex',
    '$options',
    '$expr',
    '$function',
    '$accumulator',
  ];

  const sanitized: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(query)) {
    if (dangerousOperators.includes(key)) {
      continue;
    }

    if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeMongoQuery(value as Record<string, unknown>);
    } else {
      sanitized[key] = value;
    }
  }

  return sanitized;
};
