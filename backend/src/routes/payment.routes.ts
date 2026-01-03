import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  initiatePaymentSchema,
  initiateWalletPaymentSchema,
  refundSchema,
} from '../validators/payment.validator';
import {
  initiatePayment,
  initiateWalletPayment,
  handlePaymobCallback,
  handlePaymobResponse,
  checkPaymentStatus,
  requestRefund,
} from '../controllers/payment.controller';

const router = Router();

// ==================== Customer Routes ====================

// Initiate card payment
router.post(
  '/initiate',
  authenticate,
  authorize('customer'),
  validate(initiatePaymentSchema),
  initiatePayment
);

// Initiate wallet payment
router.post(
  '/wallet',
  authenticate,
  authorize('customer'),
  validate(initiateWalletPaymentSchema),
  initiateWalletPayment
);

// Check payment status
router.get(
  '/status/:orderId',
  authenticate,
  authorize('customer'),
  checkPaymentStatus
);

// ==================== Webhook Routes (No Auth) ====================

// Paymob callback (webhook)
router.post('/callback', handlePaymobCallback);

// Paymob redirect (after payment)
router.get('/response', handlePaymobResponse);

// ==================== Admin Routes ====================

const adminRouter = Router();

// Request refund
adminRouter.post(
  '/payment/refund',
  authenticate,
  authorize('admin'),
  validate(refundSchema),
  requestRefund
);

export default router;
export { adminRouter as paymentAdminRouter };
