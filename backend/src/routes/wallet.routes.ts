import { Router } from 'express';
import {
  getBalance,
  getTransactions,
  initiateTopup,
} from '@controllers/wallet.controller';
import { authenticate, authorize } from '@middleware/auth';
import { validate } from '@middleware/validate';
import {
  topupWalletSchema,
  getTransactionsSchema,
} from '@validators/wallet.validator';

const router = Router();

// All routes require authentication as customer
router.use(authenticate, authorize('customer'));

// Wallet balance
router.get('/balance', getBalance);

// Wallet transactions
router.get('/transactions', validate(getTransactionsSchema, 'query'), getTransactions);

// Top-up wallet
router.post('/topup', validate(topupWalletSchema), initiateTopup);

export default router;
