import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../types';
import { paymobService, PaymobCallbackData, BillingData } from '../services/paymob.service';
import { successResponse } from '../utils/response';
import { StatusCodes } from 'http-status-codes';
import { Order } from '../models/Order';
import { Customer } from '../models/Customer';
import { AppError } from '../utils/errors';

/**
 * Initiate payment for an order
 * POST /api/v1/payment/initiate
 */
export const initiatePayment = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { orderId } = req.body;

    // Get customer
    const customer = await Customer.findOne({ userId }).populate('userId');
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get order
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Verify order belongs to customer
    if (order.customerId.toString() !== customer._id.toString()) {
      throw new AppError('لا يمكنك الدفع لهذا الطلب', StatusCodes.FORBIDDEN);
    }

    // Check if payment is already completed
    if (order.paymentStatus === 'paid') {
      throw new AppError('تم الدفع لهذا الطلب بالفعل', StatusCodes.BAD_REQUEST);
    }

    // Check if order can accept payment
    if (order.status === 'cancelled') {
      throw new AppError('لا يمكن الدفع لطلب ملغي', StatusCodes.BAD_REQUEST);
    }

    // Build billing data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const customerUser = customer.userId as any;
    const billingData: BillingData = {
      first_name: customerUser?.name?.split(' ')[0] || 'Customer',
      last_name: customerUser?.name?.split(' ').slice(1).join(' ') || '',
      email: customerUser?.email || 'customer@bagour.com',
      phone_number: customerUser?.phone || '01000000000',
      street: order.deliveryAddress?.address || 'N/A',
      building: order.deliveryAddress?.building || 'N/A',
      floor: order.deliveryAddress?.floor || 'N/A',
      apartment: order.deliveryAddress?.apartment || 'N/A',
      city: order.deliveryAddress?.area || 'Bagour',
    };

    // Create payment
    const result = await paymobService.createPayment(
      order._id.toString(),
      order.total,
      billingData
    );

    successResponse(res, StatusCodes.OK, 'تم إنشاء رابط الدفع بنجاح', {
      paymentKey: result.paymentKey,
      iframeUrl: result.iframeUrl,
      paymobOrderId: result.orderId,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Initiate mobile wallet payment
 * POST /api/v1/payment/wallet
 */
export const initiateWalletPayment = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { orderId, phoneNumber } = req.body;

    // Get customer
    const customer = await Customer.findOne({ userId }).populate('userId');
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get order
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Verify order belongs to customer
    if (order.customerId.toString() !== customer._id.toString()) {
      throw new AppError('لا يمكنك الدفع لهذا الطلب', StatusCodes.FORBIDDEN);
    }

    // Check if payment is already completed
    if (order.paymentStatus === 'paid') {
      throw new AppError('تم الدفع لهذا الطلب بالفعل', StatusCodes.BAD_REQUEST);
    }

    // Build billing data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const customerUser = customer.userId as any;
    const billingData: BillingData = {
      first_name: customerUser?.name?.split(' ')[0] || 'Customer',
      last_name: customerUser?.name?.split(' ').slice(1).join(' ') || '',
      email: customerUser?.email || 'customer@bagour.com',
      phone_number: phoneNumber || customerUser?.phone || '01000000000',
      street: order.deliveryAddress?.address || 'N/A',
      city: order.deliveryAddress?.area || 'Bagour',
    };

    // Create wallet payment
    const result = await paymobService.createMobileWalletPayment(
      order._id.toString(),
      order.total,
      phoneNumber,
      billingData
    );

    successResponse(res, StatusCodes.OK, 'تم إنشاء طلب الدفع بنجاح', {
      redirectUrl: result.redirectUrl,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Handle Paymob callback (webhook)
 * POST /api/v1/payment/callback
 */
export const handlePaymobCallback = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const callbackData: PaymobCallbackData = {
      obj: req.body.obj,
      type: req.body.type,
      hmac: req.query.hmac as string,
    };

    await paymobService.processCallback(callbackData);

    // Paymob expects a 200 response
    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Paymob callback error:', error);
    // Still return 200 to avoid retries for invalid data
    res.status(200).json({ success: false });
  }
};

/**
 * Handle Paymob redirect (after payment)
 * GET /api/v1/payment/response
 */
export const handlePaymobResponse = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      success,
      id,
      order: paymobOrderId,
      amount_cents,
      pending,
    } = req.query;

    const isSuccess = success === 'true' && pending === 'false';

    // Redirect to appropriate page based on payment status
    const customerAppUrl = process.env.CUSTOMER_APP_URL || 'http://localhost:3000';

    if (isSuccess) {
      res.redirect(`${customerAppUrl}/payment/success?order=${paymobOrderId}&transaction=${id}`);
    } else {
      res.redirect(`${customerAppUrl}/payment/failed?order=${paymobOrderId}`);
    }
  } catch (error) {
    next(error);
  }
};

/**
 * Check payment status
 * GET /api/v1/payment/status/:orderId
 */
export const checkPaymentStatus = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { orderId } = req.params;
    const userId = req.user?.userId;

    // Get customer
    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get order
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Verify order belongs to customer
    if (order.customerId.toString() !== customer._id.toString()) {
      throw new AppError('لا يمكنك التحقق من حالة هذا الطلب', StatusCodes.FORBIDDEN);
    }

    successResponse(res, StatusCodes.OK, 'تم جلب حالة الدفع بنجاح', {
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod,
      paidAt: order.paidAt,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Request refund (admin only)
 * POST /api/v1/admin/payment/refund
 */
export const requestRefund = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { orderId, amount } = req.body;

    // Get order
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    if (order.paymentStatus !== 'paid') {
      throw new AppError('لا يمكن استرداد طلب غير مدفوع', StatusCodes.BAD_REQUEST);
    }

    const transactionId = order.transactionId;
    if (!transactionId) {
      throw new AppError('لا توجد معاملة مرتبطة بهذا الطلب', StatusCodes.BAD_REQUEST);
    }

    // Request refund
    const amountCents = amount ? Math.round(amount * 100) : undefined;
    await paymobService.refund(transactionId.toString(), amountCents);

    successResponse(res, StatusCodes.OK, 'تم استرداد المبلغ بنجاح', {
      orderId: order._id,
      refundedAmount: amount || order.total,
    });
  } catch (error) {
    next(error);
  }
};
