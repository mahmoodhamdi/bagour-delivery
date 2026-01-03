import { Types, SortOrder } from 'mongoose';
import { Transaction, ITransaction } from '../models/Transaction';
import { Order } from '../models/Order';
import { Restaurant } from '../models/Restaurant';
import { Driver } from '../models/Driver';
import { NotFoundError, BadRequestError } from '../utils/errors';
import { TransactionType, IPaginatedResult } from '../types';

// Types
interface CreateTransactionInput {
  type: TransactionType;
  orderId?: string;
  fromUserId?: string;
  toUserId?: string;
  amount: number;
  fee?: number;
  paymentMethod?: string;
  paymentGateway?: string;
  paymentId?: string;
  paymentData?: Record<string, unknown>;
  bankName?: string;
  accountNumber?: string;
  accountName?: string;
  notes?: string;
}

interface GetTransactionsOptions {
  type?: TransactionType;
  status?: string;
  userId?: string;
  orderId?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface PayoutSummary {
  pendingAmount: number;
  processedAmount: number;
  totalTransactions: number;
  recentPayouts: ITransaction[];
}

interface WithdrawalRequest {
  driverId: string;
  amount: number;
  bankName: string;
  accountNumber: string;
  accountName: string;
}

class TransactionService {
  /**
   * Create a new transaction
   */
  async createTransaction(input: CreateTransactionInput): Promise<ITransaction> {
    const fee = input.fee || 0;
    const netAmount = input.amount - fee;

    const transaction = new Transaction({
      type: input.type,
      orderId: input.orderId ? new Types.ObjectId(input.orderId) : undefined,
      fromUserId: input.fromUserId ? new Types.ObjectId(input.fromUserId) : undefined,
      toUserId: input.toUserId ? new Types.ObjectId(input.toUserId) : undefined,
      amount: input.amount,
      fee,
      netAmount,
      currency: 'EGP',
      status: 'pending',
      paymentMethod: input.paymentMethod,
      paymentGateway: input.paymentGateway,
      paymentId: input.paymentId,
      paymentData: input.paymentData,
      bankName: input.bankName,
      accountNumber: input.accountNumber,
      accountName: input.accountName,
      notes: input.notes,
    });

    await transaction.save();
    return transaction;
  }

  /**
   * Get transaction by ID
   */
  async getTransactionById(transactionId: string): Promise<ITransaction> {
    const transaction = await Transaction.findById(transactionId)
      .populate('orderId')
      .populate('fromUserId', 'name email phone')
      .populate('toUserId', 'name email phone')
      .populate('processedBy', 'name email');

    if (!transaction) {
      throw new NotFoundError('المعاملة غير موجودة');
    }

    return transaction;
  }

  /**
   * Get transactions with filters
   */
  async getTransactions(options: GetTransactionsOptions): Promise<IPaginatedResult<ITransaction>> {
    const {
      type,
      status,
      userId,
      orderId,
      startDate,
      endDate,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: Record<string, any> = {};

    if (type) {
      query.type = type;
    }

    if (status) {
      query.status = status;
    }

    if (userId) {
      query.$or = [
        { fromUserId: new Types.ObjectId(userId) },
        { toUserId: new Types.ObjectId(userId) },
      ];
    }

    if (orderId) {
      query.orderId = new Types.ObjectId(orderId);
    }

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = startDate;
      if (endDate) query.createdAt.$lte = endDate;
    }

    const skip = (page - 1) * limit;
    const sort: { [key: string]: SortOrder } = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [transactions, total] = await Promise.all([
      Transaction.find(query)
        .populate('orderId', 'orderNumber total status')
        .populate('fromUserId', 'name email phone')
        .populate('toUserId', 'name email phone')
        .sort(sort)
        .skip(skip)
        .limit(limit),
      Transaction.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: transactions,
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
   * Update transaction status
   */
  async updateTransactionStatus(
    transactionId: string,
    status: 'pending' | 'processing' | 'completed' | 'failed',
    processedBy?: string,
    notes?: string
  ): Promise<ITransaction> {
    const transaction = await Transaction.findById(transactionId);
    if (!transaction) {
      throw new NotFoundError('المعاملة غير موجودة');
    }

    transaction.status = status;
    if (processedBy) {
      transaction.processedBy = new Types.ObjectId(processedBy);
      transaction.processedAt = new Date();
    }
    if (notes) {
      transaction.notes = notes;
    }

    await transaction.save();
    return transaction;
  }

  /**
   * Create order payment transaction
   */
  async createOrderPayment(
    orderId: string,
    customerId: string,
    amount: number,
    paymentMethod: string,
    paymentGateway?: string,
    paymentId?: string
  ): Promise<ITransaction> {
    return this.createTransaction({
      type: 'order_payment',
      orderId,
      fromUserId: customerId,
      amount,
      paymentMethod,
      paymentGateway,
      paymentId,
    });
  }

  /**
   * Create restaurant payout transaction
   */
  async createRestaurantPayout(
    orderId: string,
    restaurantId: string,
    amount: number,
    fee: number = 0
  ): Promise<ITransaction> {
    const restaurant = await Restaurant.findById(restaurantId).populate('userId');
    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    return this.createTransaction({
      type: 'restaurant_payout',
      orderId,
      toUserId: restaurant.userId?.toString(),
      amount,
      fee,
      notes: `Payout for order`,
    });
  }

  /**
   * Create driver payout transaction
   */
  async createDriverPayout(
    orderId: string,
    driverId: string,
    amount: number,
    fee: number = 0
  ): Promise<ITransaction> {
    const driver = await Driver.findById(driverId).populate('userId');
    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    return this.createTransaction({
      type: 'driver_payout',
      orderId,
      toUserId: driver.userId?.toString(),
      amount,
      fee,
      notes: `Delivery payout for order`,
    });
  }

  /**
   * Create refund transaction
   */
  async createRefund(
    orderId: string,
    customerId: string,
    amount: number,
    reason?: string
  ): Promise<ITransaction> {
    return this.createTransaction({
      type: 'refund',
      orderId,
      toUserId: customerId,
      amount,
      notes: reason || 'Order refund',
    });
  }

  /**
   * Request driver withdrawal
   */
  async requestWithdrawal(request: WithdrawalRequest): Promise<ITransaction> {
    const driver = await Driver.findById(request.driverId).populate('userId');
    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Check available balance
    const availableBalance = await this.getDriverAvailableBalance(request.driverId);
    if (request.amount > availableBalance) {
      throw new BadRequestError('الرصيد غير كافي');
    }

    if (request.amount < 50) {
      throw new BadRequestError('الحد الأدنى للسحب 50 ج.م');
    }

    return this.createTransaction({
      type: 'withdrawal',
      fromUserId: driver.userId?.toString(),
      amount: request.amount,
      bankName: request.bankName,
      accountNumber: request.accountNumber,
      accountName: request.accountName,
      notes: 'Driver withdrawal request',
    });
  }

  /**
   * Process withdrawal (admin)
   */
  async processWithdrawal(
    transactionId: string,
    processedBy: string,
    approved: boolean,
    notes?: string
  ): Promise<ITransaction> {
    const transaction = await Transaction.findById(transactionId);
    if (!transaction) {
      throw new NotFoundError('المعاملة غير موجودة');
    }

    if (transaction.type !== 'withdrawal') {
      throw new BadRequestError('هذه ليست معاملة سحب');
    }

    if (transaction.status !== 'pending') {
      throw new BadRequestError('تم معالجة هذه المعاملة بالفعل');
    }

    transaction.status = approved ? 'completed' : 'failed';
    transaction.processedBy = new Types.ObjectId(processedBy);
    transaction.processedAt = new Date();
    if (notes) {
      transaction.notes = notes;
    }

    await transaction.save();

    // If approved, update driver's withdrawn amount
    if (approved && transaction.fromUserId) {
      await Driver.findOneAndUpdate(
        { userId: transaction.fromUserId },
        { $inc: { totalWithdrawn: transaction.amount } }
      );
    }

    return transaction;
  }

  /**
   * Get driver available balance
   */
  async getDriverAvailableBalance(driverId: string): Promise<number> {
    const driver = await Driver.findById(driverId);
    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Get pending withdrawals
    const pendingWithdrawals = await Transaction.aggregate([
      {
        $match: {
          type: 'withdrawal',
          fromUserId: driver.userId,
          status: 'pending',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const pendingAmount = pendingWithdrawals[0]?.total || 0;
    const totalWithdrawn = driver.totalWithdrawn || 0;
    const totalEarnings = driver.totalEarnings || 0;

    return totalEarnings - totalWithdrawn - pendingAmount;
  }

  /**
   * Get driver withdrawal history
   */
  async getDriverWithdrawals(
    driverId: string,
    page: number = 1,
    limit: number = 20
  ): Promise<IPaginatedResult<ITransaction>> {
    const driver = await Driver.findById(driverId);
    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    return this.getTransactions({
      type: 'withdrawal',
      userId: driver.userId?.toString(),
      page,
      limit,
    });
  }

  /**
   * Get restaurant payout summary
   */
  async getRestaurantPayoutSummary(restaurantId: string): Promise<PayoutSummary> {
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    const [pendingResult, processedResult, recentPayouts] = await Promise.all([
      Transaction.aggregate([
        {
          $match: {
            type: 'restaurant_payout',
            toUserId: restaurant.userId,
            status: 'pending',
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$netAmount' },
            count: { $sum: 1 },
          },
        },
      ]),
      Transaction.aggregate([
        {
          $match: {
            type: 'restaurant_payout',
            toUserId: restaurant.userId,
            status: 'completed',
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$netAmount' },
          },
        },
      ]),
      Transaction.find({
        type: 'restaurant_payout',
        toUserId: restaurant.userId,
      })
        .sort({ createdAt: -1 })
        .limit(10)
        .populate('orderId', 'orderNumber'),
    ]);

    return {
      pendingAmount: pendingResult[0]?.total || 0,
      processedAmount: processedResult[0]?.total || 0,
      totalTransactions: pendingResult[0]?.count || 0,
      recentPayouts,
    };
  }

  /**
   * Get driver earnings summary
   */
  async getDriverEarningsSummary(driverId: string): Promise<{
    todayEarnings: number;
    weekEarnings: number;
    monthEarnings: number;
    totalEarnings: number;
    todayDeliveries: number;
    weekDeliveries: number;
    monthDeliveries: number;
    totalDeliveries: number;
    availableBalance: number;
    pendingWithdrawals: number;
    averageRating: number;
    totalRatings: number;
  }> {
    const driver = await Driver.findById(driverId);
    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    const now = new Date();
    const todayStart = new Date(now.setHours(0, 0, 0, 0));
    const weekStart = new Date(now.setDate(now.getDate() - now.getDay()));
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    // Get earnings by period
    const [todayStats, weekStats, monthStats, totalStats] = await Promise.all([
      Order.aggregate([
        {
          $match: {
            driverId: driver._id,
            status: 'delivered',
            deliveredAt: { $gte: todayStart },
          },
        },
        {
          $group: {
            _id: null,
            earnings: { $sum: '$driverEarnings' },
            count: { $sum: 1 },
          },
        },
      ]),
      Order.aggregate([
        {
          $match: {
            driverId: driver._id,
            status: 'delivered',
            deliveredAt: { $gte: weekStart },
          },
        },
        {
          $group: {
            _id: null,
            earnings: { $sum: '$driverEarnings' },
            count: { $sum: 1 },
          },
        },
      ]),
      Order.aggregate([
        {
          $match: {
            driverId: driver._id,
            status: 'delivered',
            deliveredAt: { $gte: monthStart },
          },
        },
        {
          $group: {
            _id: null,
            earnings: { $sum: '$driverEarnings' },
            count: { $sum: 1 },
          },
        },
      ]),
      Order.aggregate([
        {
          $match: {
            driverId: driver._id,
            status: 'delivered',
          },
        },
        {
          $group: {
            _id: null,
            earnings: { $sum: '$driverEarnings' },
            count: { $sum: 1 },
          },
        },
      ]),
    ]);

    // Get pending withdrawals
    const pendingWithdrawals = await Transaction.aggregate([
      {
        $match: {
          type: 'withdrawal',
          fromUserId: driver.userId,
          status: 'pending',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const availableBalance = await this.getDriverAvailableBalance(driverId);

    return {
      todayEarnings: todayStats[0]?.earnings || 0,
      weekEarnings: weekStats[0]?.earnings || 0,
      monthEarnings: monthStats[0]?.earnings || 0,
      totalEarnings: driver.totalEarnings || 0,
      todayDeliveries: todayStats[0]?.count || 0,
      weekDeliveries: weekStats[0]?.count || 0,
      monthDeliveries: monthStats[0]?.count || 0,
      totalDeliveries: driver.totalDeliveries || 0,
      availableBalance,
      pendingWithdrawals: pendingWithdrawals[0]?.total || 0,
      averageRating: driver.rating || 0,
      totalRatings: driver.totalRatings || 0,
    };
  }

  /**
   * Get platform financial summary (admin)
   */
  async getPlatformFinancialSummary(startDate?: Date, endDate?: Date): Promise<{
    totalRevenue: number;
    totalPayouts: number;
    totalRefunds: number;
    netIncome: number;
    transactionCounts: {
      payments: number;
      restaurantPayouts: number;
      driverPayouts: number;
      refunds: number;
      withdrawals: number;
    };
  }> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const dateFilter: Record<string, any> = {};
    if (startDate) dateFilter.$gte = startDate;
    if (endDate) dateFilter.$lte = endDate;

    const baseMatch = Object.keys(dateFilter).length > 0 ? { createdAt: dateFilter } : {};

    const [
      paymentsResult,
      restaurantPayoutsResult,
      driverPayoutsResult,
      refundsResult,
      withdrawalsResult,
    ] = await Promise.all([
      Transaction.aggregate([
        { $match: { ...baseMatch, type: 'order_payment', status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } },
      ]),
      Transaction.aggregate([
        { $match: { ...baseMatch, type: 'restaurant_payout', status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$netAmount' }, count: { $sum: 1 } } },
      ]),
      Transaction.aggregate([
        { $match: { ...baseMatch, type: 'driver_payout', status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$netAmount' }, count: { $sum: 1 } } },
      ]),
      Transaction.aggregate([
        { $match: { ...baseMatch, type: 'refund', status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } },
      ]),
      Transaction.aggregate([
        { $match: { ...baseMatch, type: 'withdrawal' } },
        { $group: { _id: null, count: { $sum: 1 } } },
      ]),
    ]);

    const totalRevenue = paymentsResult[0]?.total || 0;
    const restaurantPayouts = restaurantPayoutsResult[0]?.total || 0;
    const driverPayouts = driverPayoutsResult[0]?.total || 0;
    const totalRefunds = refundsResult[0]?.total || 0;
    const totalPayouts = restaurantPayouts + driverPayouts;
    const netIncome = totalRevenue - totalPayouts - totalRefunds;

    return {
      totalRevenue,
      totalPayouts,
      totalRefunds,
      netIncome,
      transactionCounts: {
        payments: paymentsResult[0]?.count || 0,
        restaurantPayouts: restaurantPayoutsResult[0]?.count || 0,
        driverPayouts: driverPayoutsResult[0]?.count || 0,
        refunds: refundsResult[0]?.count || 0,
        withdrawals: withdrawalsResult[0]?.count || 0,
      },
    };
  }

  /**
   * Get pending payouts (admin)
   */
  async getPendingPayouts(
    type: 'restaurant_payout' | 'driver_payout' | 'withdrawal',
    page: number = 1,
    limit: number = 20
  ): Promise<IPaginatedResult<ITransaction>> {
    return this.getTransactions({
      type,
      status: 'pending',
      page,
      limit,
    });
  }

  /**
   * Batch process payouts (admin)
   */
  async batchProcessPayouts(
    transactionIds: string[],
    processedBy: string,
    approved: boolean
  ): Promise<{ processed: number; failed: number }> {
    let processed = 0;
    let failed = 0;

    for (const id of transactionIds) {
      try {
        await this.updateTransactionStatus(
          id,
          approved ? 'completed' : 'failed',
          processedBy
        );
        processed++;
      } catch {
        failed++;
      }
    }

    return { processed, failed };
  }
}

export const transactionService = new TransactionService();
export default transactionService;
