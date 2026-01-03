import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  requestWithdrawalSchema,
  getTransactionsQuerySchema,
  processWithdrawalSchema,
  batchProcessPayoutsSchema,
  updateTransactionStatusSchema,
  getPendingPayoutsQuerySchema,
} from '../validators/transaction.validator';
import {
  // Driver endpoints
  getDriverEarningsSummary,
  requestWithdrawal,
  getDriverWithdrawals,
  getDriverBalance,
  // Restaurant endpoints
  getRestaurantPayoutSummary,
  getRestaurantTransactions,
  // Admin endpoints
  getAllTransactions,
  getTransactionById,
  getPlatformFinancialSummary,
  getPendingPayouts,
  processWithdrawal,
  batchProcessPayouts,
  updateTransactionStatus,
} from '../controllers/transaction.controller';

// ==================== Driver Routes ====================

const driverRouter = Router();

// Get earnings summary
driverRouter.get(
  '/earnings/summary',
  authenticate,
  authorize('driver', 'delivery'),
  getDriverEarningsSummary
);

// Get available balance
driverRouter.get(
  '/balance',
  authenticate,
  authorize('driver', 'delivery'),
  getDriverBalance
);

// Request withdrawal
driverRouter.post(
  '/withdrawals',
  authenticate,
  authorize('driver', 'delivery'),
  validate(requestWithdrawalSchema),
  requestWithdrawal
);

// Get withdrawal history
driverRouter.get(
  '/withdrawals',
  authenticate,
  authorize('driver', 'delivery'),
  getDriverWithdrawals
);

// ==================== Restaurant Routes ====================

const restaurantRouter = Router();

// Get payout summary
restaurantRouter.get(
  '/payouts/summary',
  authenticate,
  authorize('restaurant'),
  getRestaurantPayoutSummary
);

// Get transactions
restaurantRouter.get(
  '/transactions',
  authenticate,
  authorize('restaurant'),
  validate(getTransactionsQuerySchema, 'query'),
  getRestaurantTransactions
);

// ==================== Admin Routes ====================

const adminRouter = Router();

// Get all transactions
adminRouter.get(
  '/transactions',
  authenticate,
  authorize('admin'),
  validate(getTransactionsQuerySchema, 'query'),
  getAllTransactions
);

// Get platform financial summary
adminRouter.get(
  '/finance/summary',
  authenticate,
  authorize('admin'),
  getPlatformFinancialSummary
);

// Get pending payouts
adminRouter.get(
  '/payouts/pending',
  authenticate,
  authorize('admin'),
  validate(getPendingPayoutsQuerySchema, 'query'),
  getPendingPayouts
);

// Batch process payouts
adminRouter.post(
  '/payouts/batch',
  authenticate,
  authorize('admin'),
  validate(batchProcessPayoutsSchema),
  batchProcessPayouts
);

// Get transaction by ID
adminRouter.get(
  '/transactions/:id',
  authenticate,
  authorize('admin'),
  getTransactionById
);

// Update transaction status
adminRouter.put(
  '/transactions/:id/status',
  authenticate,
  authorize('admin'),
  validate(updateTransactionStatusSchema),
  updateTransactionStatus
);

// Process withdrawal
adminRouter.put(
  '/withdrawals/:id/process',
  authenticate,
  authorize('admin'),
  validate(processWithdrawalSchema),
  processWithdrawal
);

export {
  driverRouter as transactionDriverRouter,
  restaurantRouter as transactionRestaurantRouter,
  adminRouter as transactionAdminRouter,
};
