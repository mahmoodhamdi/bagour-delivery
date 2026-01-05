import { Request, Response, NextFunction } from 'express';
import { walletService } from '../services/wallet.service';
import { sendSuccess, sendCreated, sendPaginated } from '../utils/response';
import { AuthRequest } from '../types';

/**
 * Get customer wallet balance
 * @route GET /api/v1/customer/wallet/balance
 * @access Private (Customer)
 */
export const getBalance = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const customerId = (req as AuthRequest).user?.userId;

    if (!customerId) {
      throw new Error('معرف المستخدم غير موجود');
    }

    const balance = await walletService.getBalance(customerId);

    sendSuccess(res, balance, 'تم الحصول على رصيد المحفظة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get wallet transactions
 * @route GET /api/v1/customer/wallet/transactions
 * @access Private (Customer)
 */
export const getTransactions = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const customerId = (req as AuthRequest).user?.userId;

    if (!customerId) {
      throw new Error('معرف المستخدم غير موجود');
    }

    const { page, limit, type, startDate, endDate } = req.query;

    const options = {
      customerId,
      page: page ? parseInt(page as string, 10) : 1,
      limit: limit ? parseInt(limit as string, 10) : 20,
      type: type as string | undefined,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
    };

    const result = await walletService.getTransactions(options);

    sendPaginated(res, result.data, result.pagination, 'تم الحصول على المعاملات بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Initiate wallet top-up
 * @route POST /api/v1/customer/wallet/topup
 * @access Private (Customer)
 */
export const initiateTopup = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const customerId = (req as AuthRequest).user?.userId;

    if (!customerId) {
      throw new Error('معرف المستخدم غير موجود');
    }

    const { amount, paymentMethod, phoneNumber } = req.body;

    const result = await walletService.initiateTopup({
      customerId,
      amount,
      paymentMethod,
      phoneNumber,
    });

    sendCreated(
      res,
      result,
      'تم إنشاء طلب شحن المحفظة بنجاح. سيتم توجيهك إلى صفحة الدفع'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Confirm wallet top-up (called by payment callback)
 * This is typically called internally, not by the frontend
 */
export const confirmTopup = async (
  transactionId: string,
  paymentId: string
): Promise<void> => {
  await walletService.confirmTopup(transactionId, paymentId);
};
