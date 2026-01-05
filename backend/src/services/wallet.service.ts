import { Types } from 'mongoose';
import { Customer, ICustomer } from '../models/Customer';
import { Transaction, ITransaction } from '../models/Transaction';
import { User } from '../models/User';
import { NotFoundError, BadRequestError } from '../utils/errors';
import { IPaginatedResult } from '../types';
import { paymobService } from './paymob.service';
import { transactionService } from './transaction.service';

interface TopupWalletInput {
  customerId: string;
  amount: number;
  paymentMethod: 'card' | 'mobile_wallet';
  phoneNumber?: string;
}

interface GetWalletTransactionsOptions {
  customerId: string;
  type?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
}

interface WalletBalance {
  balance: number;
  totalTopups: number;
  totalSpent: number;
}

class WalletService {
  /**
   * Get customer wallet balance
   */
  async getBalance(customerId: string): Promise<WalletBalance> {
    const customer = await Customer.findOne({ userId: new Types.ObjectId(customerId) });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    return {
      balance: customer.walletBalance,
      totalTopups: customer.totalWalletTopups,
      totalSpent: customer.totalWalletSpent,
    };
  }

  /**
   * Get wallet transactions
   */
  async getTransactions(
    options: GetWalletTransactionsOptions
  ): Promise<IPaginatedResult<ITransaction>> {
    const { customerId, type, startDate, endDate, page = 1, limit = 20 } = options;

    const customer = await Customer.findOne({ userId: new Types.ObjectId(customerId) });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    const query: Record<string, unknown> = {
      $or: [
        { fromUserId: new Types.ObjectId(customerId) },
        { toUserId: new Types.ObjectId(customerId) },
      ],
      type: { $in: ['wallet_topup', 'order_payment', 'refund'] },
    };

    if (type) {
      query.type = type === 'topup' ? 'wallet_topup' : type;
    }

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        (query.createdAt as Record<string, unknown>).$gte = startDate;
      }
      if (endDate) {
        (query.createdAt as Record<string, unknown>).$lte = endDate;
      }
    }

    const skip = (page - 1) * limit;

    const [transactions, total] = await Promise.all([
      Transaction.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('orderId', 'orderNumber')
        .lean(),
      Transaction.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: transactions as ITransaction[],
      pagination: {
        total,
        page,
        limit,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1,
      },
    };
  }

  /**
   * Initiate wallet top-up
   */
  async initiateTopup(input: TopupWalletInput): Promise<{ redirectUrl: string; transactionId: string }> {
    const { customerId, amount, paymentMethod, phoneNumber } = input;

    // Validate customer
    const customer = await Customer.findOne({ userId: new Types.ObjectId(customerId) });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    const user = await User.findById(customerId);

    if (!user) {
      throw new NotFoundError('المستخدم غير موجود');
    }

    // Create pending transaction
    const transaction = await transactionService.createTransaction({
      type: 'wallet_topup',
      toUserId: customerId,
      amount,
      fee: 0,
      paymentMethod,
      paymentGateway: 'paymob',
    });

    // Prepare billing data
    const billingData = {
      email: user.email,
      first_name: user.name.split(' ')[0] || 'Customer',
      last_name: user.name.split(' ').slice(1).join(' ') || 'User',
      phone_number: user.phone || phoneNumber || '01000000000',
      street: 'NA',
      building: 'NA',
      floor: 'NA',
      apartment: 'NA',
      city: 'Bagour',
      country: 'EG',
      shipping_method: 'NA',
    };

    try {
      // Create payment via Paymob
      const payment = await paymobService.createWalletTopupPayment(
        transaction._id.toString(),
        amount,
        billingData,
        paymentMethod,
        phoneNumber
      );

      // Update transaction with Paymob order ID
      transaction.paymentId = payment.paymobOrderId;
      transaction.paymentData = {
        paymobOrderId: payment.paymobOrderId,
      };
      await transaction.save();

      return {
        redirectUrl: payment.redirectUrl,
        transactionId: transaction._id.toString(),
      };
    } catch (error) {
      // Mark transaction as failed
      transaction.status = 'failed';
      await transaction.save();
      throw error;
    }
  }

  /**
   * Confirm wallet top-up after payment
   */
  async confirmTopup(transactionId: string, paymentId: string): Promise<ICustomer> {
    const transaction = await Transaction.findById(transactionId);

    if (!transaction) {
      throw new NotFoundError('المعاملة غير موجودة');
    }

    if (transaction.type !== 'wallet_topup') {
      throw new BadRequestError('نوع المعاملة غير صحيح');
    }

    if (transaction.status === 'completed') {
      throw new BadRequestError('المعاملة مكتملة بالفعل');
    }

    if (!transaction.toUserId) {
      throw new BadRequestError('معرف العميل غير موجود في المعاملة');
    }

    // Update transaction
    transaction.status = 'completed';
    transaction.paymentId = paymentId;
    transaction.processedAt = new Date();
    await transaction.save();

    // Update customer wallet balance
    const customer = await Customer.findOne({ userId: transaction.toUserId });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    customer.walletBalance += transaction.amount;
    customer.totalWalletTopups += transaction.amount;
    await customer.save();

    return customer;
  }

  /**
   * Deduct from wallet for order payment
   */
  async deductFromWallet(
    customerId: string,
    orderId: string,
    amount: number
  ): Promise<{ success: boolean; newBalance: number }> {
    const customer = await Customer.findOne({ userId: new Types.ObjectId(customerId) });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    if (customer.walletBalance < amount) {
      throw new BadRequestError('رصيد المحفظة غير كافٍ');
    }

    // Create transaction
    await transactionService.createTransaction({
      type: 'order_payment',
      orderId,
      fromUserId: customerId,
      amount,
      fee: 0,
      paymentMethod: 'wallet',
    });

    // Deduct from wallet
    customer.walletBalance -= amount;
    customer.totalWalletSpent += amount;
    await customer.save();

    // Mark transaction as completed
    const transaction = await Transaction.findOne({
      orderId: new Types.ObjectId(orderId),
      type: 'order_payment',
      status: 'pending',
    }).sort({ createdAt: -1 });

    if (transaction) {
      transaction.status = 'completed';
      transaction.processedAt = new Date();
      await transaction.save();
    }

    return {
      success: true,
      newBalance: customer.walletBalance,
    };
  }

  /**
   * Refund to wallet
   */
  async refundToWallet(
    customerId: string,
    orderId: string,
    amount: number
  ): Promise<ICustomer> {
    const customer = await Customer.findOne({ userId: new Types.ObjectId(customerId) });

    if (!customer) {
      throw new NotFoundError('بيانات العميل غير موجودة');
    }

    // Create refund transaction
    const transaction = await transactionService.createTransaction({
      type: 'refund',
      orderId,
      toUserId: customerId,
      amount,
      fee: 0,
      paymentMethod: 'wallet',
      notes: 'استرجاع مبلغ الطلب إلى المحفظة',
    });

    // Add to wallet
    customer.walletBalance += amount;
    await customer.save();

    // Mark transaction as completed
    transaction.status = 'completed';
    transaction.processedAt = new Date();
    await transaction.save();

    return customer;
  }
}

export const walletService = new WalletService();
export default walletService;
