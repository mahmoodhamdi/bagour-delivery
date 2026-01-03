import { Response, NextFunction } from 'express';
import { AuthRequest, TransactionType } from '../types';
import { transactionService } from '../services/transaction.service';
import { successResponse, paginatedResponse } from '../utils/response';
import { StatusCodes } from 'http-status-codes';
import { Driver } from '../models/Driver';
import { Restaurant } from '../models/Restaurant';
import { AppError } from '../utils/errors';

// ==================== Driver Endpoints ====================

/**
 * Get driver earnings summary
 * GET /api/v1/driver/earnings
 */
export const getDriverEarningsSummary = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const summary = await transactionService.getDriverEarningsSummary(driver._id.toString());

    successResponse(res, StatusCodes.OK, 'تم جلب ملخص الأرباح بنجاح', summary);
  } catch (error) {
    next(error);
  }
};

/**
 * Request withdrawal
 * POST /api/v1/driver/withdrawals
 */
export const requestWithdrawal = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { amount, bankName, accountNumber, accountName } = req.body;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const transaction = await transactionService.requestWithdrawal({
      driverId: driver._id.toString(),
      amount,
      bankName,
      accountNumber,
      accountName,
    });

    successResponse(res, StatusCodes.CREATED, 'تم تقديم طلب السحب بنجاح', {
      withdrawal: transaction,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver withdrawals history
 * GET /api/v1/driver/withdrawals
 */
export const getDriverWithdrawals = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { page, limit } = req.query;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const result = await transactionService.getDriverWithdrawals(
      driver._id.toString(),
      page ? Number(page) : undefined,
      limit ? Number(limit) : undefined
    );

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب سجل السحوبات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver available balance
 * GET /api/v1/driver/balance
 */
export const getDriverBalance = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const availableBalance = await transactionService.getDriverAvailableBalance(
      driver._id.toString()
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الرصيد المتاح بنجاح', {
      availableBalance,
      totalEarnings: driver.totalEarnings || 0,
      totalWithdrawn: driver.totalWithdrawn || 0,
    });
  } catch (error) {
    next(error);
  }
};

// ==================== Restaurant Endpoints ====================

/**
 * Get restaurant payout summary
 * GET /api/v1/restaurant/payouts/summary
 */
export const getRestaurantPayoutSummary = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const summary = await transactionService.getRestaurantPayoutSummary(
      restaurant._id.toString()
    );

    successResponse(res, StatusCodes.OK, 'تم جلب ملخص المدفوعات بنجاح', summary);
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant transactions
 * GET /api/v1/restaurant/transactions
 */
export const getRestaurantTransactions = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { type, status, startDate, endDate, page, limit } = req.query;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const result = await transactionService.getTransactions({
      type: type as TransactionType | undefined,
      status: status as string | undefined,
      userId: restaurant.userId?.toString(),
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب المعاملات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

// ==================== Admin Endpoints ====================

/**
 * Get all transactions
 * GET /api/v1/admin/transactions
 */
export const getAllTransactions = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      type,
      status,
      userId,
      orderId,
      startDate,
      endDate,
      page,
      limit,
      sortBy,
      sortOrder,
    } = req.query;

    const result = await transactionService.getTransactions({
      type: type as TransactionType | undefined,
      status: status as string | undefined,
      userId: userId as string | undefined,
      orderId: orderId as string | undefined,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
      sortBy: sortBy as string | undefined,
      sortOrder: sortOrder as 'asc' | 'desc' | undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب المعاملات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get transaction by ID
 * GET /api/v1/admin/transactions/:id
 */
export const getTransactionById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const transaction = await transactionService.getTransactionById(id);

    successResponse(res, StatusCodes.OK, 'تم جلب المعاملة بنجاح', { transaction });
  } catch (error) {
    next(error);
  }
};

/**
 * Get platform financial summary
 * GET /api/v1/admin/finance/summary
 */
export const getPlatformFinancialSummary = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { startDate, endDate } = req.query;

    const summary = await transactionService.getPlatformFinancialSummary(
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الملخص المالي بنجاح', summary);
  } catch (error) {
    next(error);
  }
};

/**
 * Get pending payouts
 * GET /api/v1/admin/payouts/pending
 */
export const getPendingPayouts = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { type, page, limit } = req.query;

    const validTypes = ['restaurant_payout', 'driver_payout', 'withdrawal'] as const;
    const payoutType = validTypes.includes(type as (typeof validTypes)[number])
      ? (type as 'restaurant_payout' | 'driver_payout' | 'withdrawal')
      : 'withdrawal';

    const result = await transactionService.getPendingPayouts(
      payoutType,
      page ? Number(page) : undefined,
      limit ? Number(limit) : undefined
    );

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب المدفوعات المعلقة بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Process withdrawal
 * PUT /api/v1/admin/withdrawals/:id/process
 */
export const processWithdrawal = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { approved, notes } = req.body;
    const userId = req.user?.userId;

    const transaction = await transactionService.processWithdrawal(
      id,
      userId || '',
      approved,
      notes
    );

    const message = approved
      ? 'تم الموافقة على طلب السحب بنجاح'
      : 'تم رفض طلب السحب';

    successResponse(res, StatusCodes.OK, message, { transaction });
  } catch (error) {
    next(error);
  }
};

/**
 * Batch process payouts
 * POST /api/v1/admin/payouts/batch
 */
export const batchProcessPayouts = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { transactionIds, approved } = req.body;
    const userId = req.user?.userId;

    const result = await transactionService.batchProcessPayouts(
      transactionIds,
      userId || '',
      approved
    );

    successResponse(res, StatusCodes.OK, 'تم معالجة المدفوعات', result);
  } catch (error) {
    next(error);
  }
};

/**
 * Update transaction status
 * PUT /api/v1/admin/transactions/:id/status
 */
export const updateTransactionStatus = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;
    const userId = req.user?.userId;

    const transaction = await transactionService.updateTransactionStatus(
      id,
      status,
      userId,
      notes
    );

    successResponse(res, StatusCodes.OK, 'تم تحديث حالة المعاملة بنجاح', { transaction });
  } catch (error) {
    next(error);
  }
};
