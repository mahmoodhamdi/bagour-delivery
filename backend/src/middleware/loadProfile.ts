/// <reference path="../types/express.d.ts" />
import { Request, Response, NextFunction } from 'express';
import { Customer, Driver, Restaurant } from '../models';
import { AppError } from '../utils/errors';

/**
 * Profile loader middleware. Resolves the role-specific document
 * (Customer, Restaurant, Driver) for the authenticated user and attaches
 * its `_id` to `req.{customerId,restaurantId,driverId}` so controllers can
 * call service methods that take a profile ID without each repeating the
 * lookup.
 *
 * Must run AFTER `authenticate`.
 */
export const loadDriverProfile = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }
    const driver = await Driver.findOne({ userId: req.user.userId }).select('_id');
    if (!driver) {
      throw new AppError('ملف السائق غير موجود', 404);
    }
    req.driverId = driver._id.toString();
    next();
  } catch (error) {
    next(error);
  }
};

export const loadCustomerProfile = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }
    const customer = await Customer.findOne({ userId: req.user.userId }).select('_id');
    if (!customer) {
      throw new AppError('ملف العميل غير موجود', 404);
    }
    req.customerId = customer._id.toString();
    next();
  } catch (error) {
    next(error);
  }
};

export const loadRestaurantProfile = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }
    const restaurant = await Restaurant.findOne({ userId: req.user.userId }).select('_id');
    if (!restaurant) {
      throw new AppError('ملف المطعم غير موجود', 404);
    }
    req.restaurantId = restaurant._id.toString();
    next();
  } catch (error) {
    next(error);
  }
};
