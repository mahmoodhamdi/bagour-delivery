import axios, { AxiosInstance } from 'axios';
import crypto from 'crypto';
import { BadRequestError, ServiceUnavailableError } from '../utils/errors';
import { Transaction } from '../models/Transaction';
import { Order } from '../models/Order';
import { Types } from 'mongoose';
import { emitToUser, emitToOrder } from '../config/socket';

// Paymob API URLs
const PAYMOB_BASE_URL = 'https://accept.paymob.com/api';

// Types
export interface PaymobAuthResponse {
  token: string;
}

export interface PaymobOrderResponse {
  id: number;
  created_at: string;
  delivery_needed: boolean;
  merchant: {
    id: number;
    created_at: string;
    state: string;
  };
  amount_cents: number;
  currency: string;
}

export interface PaymobPaymentKeyResponse {
  token: string;
}

export interface PaymobTransactionData {
  id: number;
  pending: boolean;
  amount_cents: number;
  success: boolean;
  is_auth: boolean;
  is_capture: boolean;
  is_standalone_payment: boolean;
  is_voided: boolean;
  is_refunded: boolean;
  is_3d_secure: boolean;
  integration_id: number;
  has_parent_transaction: boolean;
  order: {
    id: number;
    created_at: string;
  };
  created_at: string;
  currency: string;
  source_data: {
    type: string;
    pan: string;
    sub_type: string;
  };
  error_occured: boolean;
  owner: number;
  data: {
    gateway_integration_pk: number;
    klass: string;
    created_at: string;
    amount: number;
    currency: string;
    migs_order: {
      id: string;
    };
    migs_result: string;
    migs_transaction: {
      id: string;
    };
    txn_response_code: string;
    merchant: string;
    card_num: string;
    message: string;
    order_info: string;
  };
}

export interface PaymobCallbackData {
  obj: PaymobTransactionData;
  type: string;
  hmac: string;
}

export interface CreatePaymentResult {
  paymentKey: string;
  iframeUrl: string;
  orderId: number;
}

export interface BillingData {
  first_name: string;
  last_name: string;
  email: string;
  phone_number: string;
  street?: string;
  building?: string;
  floor?: string;
  apartment?: string;
  city?: string;
  country?: string;
  postal_code?: string;
  state?: string;
}

class PaymobService {
  private apiKey: string;
  private integrationId: string;
  private iframeId: string;
  private hmacSecret: string;
  private client: AxiosInstance;

  constructor() {
    this.apiKey = process.env.PAYMOB_API_KEY || '';
    this.integrationId = process.env.PAYMOB_INTEGRATION_ID || '';
    this.iframeId = process.env.PAYMOB_IFRAME_ID || '';
    this.hmacSecret = process.env.PAYMOB_HMAC_SECRET || '';

    this.client = axios.create({
      baseURL: PAYMOB_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  /**
   * Step 1: Get authentication token from Paymob
   */
  private async getAuthToken(): Promise<string> {
    try {
      const response = await this.client.post<PaymobAuthResponse>('/auth/tokens', {
        api_key: this.apiKey,
      });

      return response.data.token;
    } catch (error) {
      console.error('Paymob auth error:', error);
      throw new ServiceUnavailableError('فشل في الاتصال ببوابة الدفع');
    }
  }

  /**
   * Step 2: Create order in Paymob
   */
  private async createPaymobOrder(
    authToken: string,
    amountCents: number,
    merchantOrderId: string
  ): Promise<PaymobOrderResponse> {
    try {
      const response = await this.client.post<PaymobOrderResponse>('/ecommerce/orders', {
        auth_token: authToken,
        delivery_needed: false,
        amount_cents: amountCents,
        currency: 'EGP',
        merchant_order_id: merchantOrderId,
        items: [],
      });

      return response.data;
    } catch (error) {
      console.error('Paymob order creation error:', error);
      throw new ServiceUnavailableError('فشل في إنشاء طلب الدفع');
    }
  }

  /**
   * Step 3: Generate payment key
   */
  private async getPaymentKey(
    authToken: string,
    orderId: number,
    amountCents: number,
    billingData: BillingData,
    expiration?: number
  ): Promise<string> {
    try {
      const response = await this.client.post<PaymobPaymentKeyResponse>('/acceptance/payment_keys', {
        auth_token: authToken,
        amount_cents: amountCents,
        expiration: expiration || 3600, // 1 hour default
        order_id: orderId,
        billing_data: {
          first_name: billingData.first_name,
          last_name: billingData.last_name,
          email: billingData.email,
          phone_number: billingData.phone_number,
          street: billingData.street || 'N/A',
          building: billingData.building || 'N/A',
          floor: billingData.floor || 'N/A',
          apartment: billingData.apartment || 'N/A',
          city: billingData.city || 'Bagour',
          country: billingData.country || 'EG',
          postal_code: billingData.postal_code || 'N/A',
          state: billingData.state || 'Menoufia',
        },
        currency: 'EGP',
        integration_id: parseInt(this.integrationId),
      });

      return response.data.token;
    } catch (error) {
      console.error('Paymob payment key error:', error);
      throw new ServiceUnavailableError('فشل في إنشاء مفتاح الدفع');
    }
  }

  /**
   * Create payment for an order
   */
  async createPayment(
    orderId: string,
    amount: number,
    billingData: BillingData
  ): Promise<CreatePaymentResult> {
    // Convert amount to cents (piasters)
    const amountCents = Math.round(amount * 100);

    // Step 1: Get auth token
    const authToken = await this.getAuthToken();

    // Step 2: Create Paymob order
    const paymobOrder = await this.createPaymobOrder(authToken, amountCents, orderId);

    // Step 3: Generate payment key
    const paymentKey = await this.getPaymentKey(
      authToken,
      paymobOrder.id,
      amountCents,
      billingData
    );

    // Generate iframe URL
    const iframeUrl = `https://accept.paymob.com/api/acceptance/iframes/${this.iframeId}?payment_token=${paymentKey}`;

    // Create pending transaction
    const transaction = new Transaction({
      type: 'order_payment',
      orderId: new Types.ObjectId(orderId),
      amount: amount,
      fee: 0,
      netAmount: amount,
      currency: 'EGP',
      status: 'pending',
      paymentMethod: 'card',
      paymentGateway: 'paymob',
      paymentId: paymobOrder.id.toString(),
      paymentData: {
        paymobOrderId: paymobOrder.id,
        paymentKey: paymentKey,
      },
    });

    await transaction.save();

    // Update order with transaction reference
    await Order.findByIdAndUpdate(orderId, {
      transactionId: transaction._id,
    });

    return {
      paymentKey,
      iframeUrl,
      orderId: paymobOrder.id,
    };
  }

  /**
   * Verify HMAC signature from Paymob callback
   */
  verifyHmac(data: PaymobCallbackData): boolean {
    const obj = data.obj;

    // Concatenate the values in the required order
    const concatenatedString = [
      obj.amount_cents,
      obj.created_at,
      obj.currency,
      obj.error_occured,
      obj.has_parent_transaction,
      obj.id,
      obj.integration_id,
      obj.is_3d_secure,
      obj.is_auth,
      obj.is_capture,
      obj.is_refunded,
      obj.is_standalone_payment,
      obj.is_voided,
      obj.order.id,
      obj.owner,
      obj.pending,
      obj.source_data.pan,
      obj.source_data.sub_type,
      obj.source_data.type,
      obj.success,
    ].join('');

    // Generate HMAC
    const calculatedHmac = crypto
      .createHmac('sha512', this.hmacSecret)
      .update(concatenatedString)
      .digest('hex');

    return calculatedHmac === data.hmac;
  }

  /**
   * Process payment callback from Paymob
   */
  async processCallback(data: PaymobCallbackData): Promise<void> {
    // Verify HMAC
    if (!this.verifyHmac(data)) {
      console.error('Invalid HMAC signature');
      throw new BadRequestError('توقيع غير صالح');
    }

    const transactionData = data.obj;
    const paymobOrderId = transactionData.order.id.toString();

    // Find the transaction
    const transaction = await Transaction.findOne({
      paymentId: paymobOrderId,
      paymentGateway: 'paymob',
    });

    if (!transaction) {
      console.error('Transaction not found for Paymob order:', paymobOrderId);
      return;
    }

    // Update transaction status
    if (transactionData.success && !transactionData.error_occured) {
      transaction.status = 'completed';
      transaction.paymentData = {
        ...transaction.paymentData,
        paymobTransactionId: transactionData.id,
        cardLastFour: transactionData.source_data.pan,
        cardType: transactionData.source_data.sub_type,
      };

      // Update order payment status
      if (transaction.orderId) {
        const order = await Order.findByIdAndUpdate(
          transaction.orderId,
          {
            paymentStatus: 'paid',
            paidAt: new Date(),
            paymentId: transactionData.id.toString(),
          },
          { new: true }
        );

        // Emit payment success events
        if (order) {
          emitToOrder(order._id.toString(), 'payment:success', {
            orderId: order._id,
            orderNumber: order.orderNumber,
            paymentStatus: 'paid',
          });

          if (order.customerId) {
            emitToUser(order.customerId.toString(), 'order:payment:success', {
              orderId: order._id,
              orderNumber: order.orderNumber,
            });
          }
        }
      }
    } else {
      transaction.status = 'failed';
      transaction.paymentData = {
        ...transaction.paymentData,
        error: transactionData.data?.message || 'Payment failed',
        paymobTransactionId: transactionData.id,
      };

      // Update order payment status
      if (transaction.orderId) {
        const order = await Order.findByIdAndUpdate(
          transaction.orderId,
          {
            paymentStatus: 'failed',
          },
          { new: true }
        );

        // Emit payment failed events
        if (order) {
          emitToOrder(order._id.toString(), 'payment:failed', {
            orderId: order._id,
            orderNumber: order.orderNumber,
            paymentStatus: 'failed',
          });

          if (order.customerId) {
            emitToUser(order.customerId.toString(), 'order:payment:failed', {
              orderId: order._id,
              orderNumber: order.orderNumber,
            });
          }
        }
      }
    }

    await transaction.save();
  }

  /**
   * Request refund for a transaction
   */
  async refund(transactionId: string, amountCents?: number): Promise<boolean> {
    try {
      const transaction = await Transaction.findById(transactionId);
      if (!transaction) {
        throw new BadRequestError('المعاملة غير موجودة');
      }

      if (transaction.status !== 'completed') {
        throw new BadRequestError('لا يمكن استرداد معاملة غير مكتملة');
      }

      const paymobTransactionId = (transaction.paymentData as { paymobTransactionId?: number })?.paymobTransactionId;
      if (!paymobTransactionId) {
        throw new BadRequestError('معرف معاملة Paymob غير موجود');
      }

      // Get auth token
      const authToken = await this.getAuthToken();

      // Request refund
      const refundAmount = amountCents || Math.round(transaction.amount * 100);

      await this.client.post('/acceptance/void_refund/refund', {
        auth_token: authToken,
        transaction_id: paymobTransactionId,
        amount_cents: refundAmount,
      });

      // Create refund transaction
      const refundTransaction = new Transaction({
        type: 'refund',
        orderId: transaction.orderId,
        amount: refundAmount / 100,
        fee: 0,
        netAmount: refundAmount / 100,
        currency: 'EGP',
        status: 'completed',
        paymentMethod: 'card',
        paymentGateway: 'paymob',
        paymentId: paymobTransactionId.toString(),
        paymentData: {
          originalTransactionId: transaction._id,
          refundAmount: refundAmount,
        },
      });

      await refundTransaction.save();

      // Update original transaction
      transaction.paymentData = {
        ...transaction.paymentData,
        refunded: true,
        refundTransactionId: refundTransaction._id,
      };
      await transaction.save();

      // Update order payment status
      if (transaction.orderId) {
        await Order.findByIdAndUpdate(transaction.orderId, {
          paymentStatus: 'refunded',
        });
      }

      return true;
    } catch (error) {
      console.error('Paymob refund error:', error);
      throw new ServiceUnavailableError('فشل في استرداد المبلغ');
    }
  }

  /**
   * Check payment status
   */
  async checkPaymentStatus(paymobOrderId: string): Promise<string> {
    const transaction = await Transaction.findOne({
      paymentId: paymobOrderId,
      paymentGateway: 'paymob',
    });

    if (!transaction) {
      throw new BadRequestError('المعاملة غير موجودة');
    }

    return transaction.status;
  }

  /**
   * Generate mobile wallet payment URL
   */
  async createMobileWalletPayment(
    orderId: string,
    amount: number,
    phoneNumber: string,
    billingData: BillingData
  ): Promise<{ redirectUrl: string }> {
    const amountCents = Math.round(amount * 100);

    // Get auth token
    const authToken = await this.getAuthToken();

    // Create Paymob order
    const paymobOrder = await this.createPaymobOrder(authToken, amountCents, orderId);

    // Get payment key for mobile wallet
    const paymentKey = await this.getPaymentKey(
      authToken,
      paymobOrder.id,
      amountCents,
      billingData
    );

    // Create wallet payment
    const walletIntegrationId = process.env.PAYMOB_WALLET_INTEGRATION_ID || this.integrationId;

    const response = await this.client.post('/acceptance/payments/pay', {
      source: {
        identifier: phoneNumber,
        subtype: 'WALLET',
      },
      payment_token: paymentKey,
    }, {
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Create pending transaction
    const transaction = new Transaction({
      type: 'order_payment',
      orderId: new Types.ObjectId(orderId),
      amount: amount,
      fee: 0,
      netAmount: amount,
      currency: 'EGP',
      status: 'pending',
      paymentMethod: 'wallet',
      paymentGateway: 'paymob',
      paymentId: paymobOrder.id.toString(),
      paymentData: {
        paymobOrderId: paymobOrder.id,
        walletIntegrationId,
        phoneNumber,
      },
    });

    await transaction.save();

    // Update order with transaction reference
    await Order.findByIdAndUpdate(orderId, {
      transactionId: transaction._id,
    });

    return {
      redirectUrl: response.data.redirect_url || '',
    };
  }
}

export const paymobService = new PaymobService();
export default paymobService;
