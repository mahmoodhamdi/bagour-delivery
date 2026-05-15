import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { AppError } from '../utils/errors';

type ValidationSource = 'body' | 'query' | 'params';

/**
 * Validation middleware factory
 * @param schema - Joi validation schema
 * @param source - Source of data to validate (body, query, params)
 */
export const validate = (
  schema: Joi.ObjectSchema,
  source: ValidationSource = 'body'
) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const dataToValidate = req[source];

    const { error, value } = schema.validate(dataToValidate, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors: Record<string, string[]> = {};

      error.details.forEach((detail) => {
        const key = detail.path.join('.');
        if (!errors[key]) {
          errors[key] = [];
        }
        errors[key].push(detail.message);
      });

      throw new AppError(
        'بيانات غير صالحة',
        400,
        true,
        'VALIDATION_ERROR',
        errors
      );
    }

    // Replace the source data with validated and sanitized data.
    // Express 5 / connect makes `req.query` a getter-only property, so we
    // mutate it in place for `query` and assign for the other sources.
    if (source === 'query') {
      const target = req.query as Record<string, unknown>;
      for (const key of Object.keys(target)) {
        delete target[key];
      }
      Object.assign(target, value);
    } else {
      req[source] = value;
    }
    next();
  };
};

/**
 * Validate multiple sources
 */
export const validateMultiple = (
  schemas: Partial<Record<ValidationSource, Joi.ObjectSchema>>
) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const allErrors: Record<string, string[]> = {};

    for (const [source, schema] of Object.entries(schemas)) {
      if (!schema) continue;

      const dataToValidate = req[source as ValidationSource];
      const { error, value } = schema.validate(dataToValidate, {
        abortEarly: false,
        stripUnknown: true,
      });

      if (error) {
        error.details.forEach((detail) => {
          const key = `${source}.${detail.path.join('.')}`;
          if (!allErrors[key]) {
            allErrors[key] = [];
          }
          allErrors[key].push(detail.message);
        });
      } else if (source === 'query') {
        const target = req.query as Record<string, unknown>;
        for (const key of Object.keys(target)) {
          delete target[key];
        }
        Object.assign(target, value);
      } else {
        req[source as ValidationSource] = value;
      }
    }

    if (Object.keys(allErrors).length > 0) {
      throw new AppError(
        'بيانات غير صالحة',
        400,
        true,
        'VALIDATION_ERROR',
        allErrors
      );
    }

    next();
  };
};
