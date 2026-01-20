import mongoose, { Types } from 'mongoose';
import { Payout, IPayout, PayoutMethod, IAccountDetails } from '../models/Payout';
import { Restaurant } from '../models/Restaurant';
import { Order } from '../models/Order';
import { Transaction } from '../models/Transaction';
import { Setting } from '../models/Setting';
import { NotFoundError, BadRequestError, ConflictError } from '../utils/errors';
import { emitToUser, getIO } from '../config/socket';

interface CreatePayoutInput {
  amount: number;
  method: PayoutMethod;
  accountDetails: IAccountDetails;
  notes?: string;
}

interface PayoutBalance {
  totalEarnings: number;
  withdrawn: number;
  pending: number;
  available: number;
}

interface PaginatedPayouts {
  payouts: IPayout[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

class PayoutService {
  /**
   * Create a new payout request
   */
  async createPayout(restaurantId: string, data: CreatePayoutInput): Promise<IPayout> {
    // Check for pending payouts
    const pendingPayout = await Payout.findOne({
      restaurantId,
      status: { $in: ['pending', 'processing'] },
    });

    if (pendingPayout) {
      throw new ConflictError('لديك طلب سحب قيد المعالجة بالفعل');
    }

    // Get restaurant
    const restaurant = await Restaurant.findById(restaurantId).populate('userId', '_id');
    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    // Calculate available balance
    const balance = await this.getBalance(restaurantId);

    if (data.amount > balance.available) {
      throw new BadRequestError(`الرصيد المتاح للسحب: ${balance.available} جنيه`);
    }

    // Create payout request
    const payout = new Payout({
      restaurantId,
      amount: data.amount,
      method: data.method,
      accountDetails: data.accountDetails,
      notes: data.notes,
      status: 'pending',
    });

    await payout.save();

    // Create transaction record
    await Transaction.create({
      type: 'restaurant_payout',
      amount: data.amount,
      fee: 0,
      netAmount: data.amount,
      status: 'pending',
      toUserId: restaurant.userId,
      notes: `طلب سحب #${payout.reference} - Payout ID: ${payout._id}`,
    });

    // Notify admin about new payout request
    const io = getIO();
    if (io) {
      io.to('admin').emit('payout:new', {
        payoutId: payout._id,
        restaurantId,
        restaurantName: restaurant.name,
        amount: data.amount,
        method: data.method,
        reference: payout.reference,
      });
    }

    return payout;
  }

  /**
   * Get restaurant balance
   */
  async getBalance(restaurantId: string): Promise<PayoutBalance> {
    const restaurantObjectId = new mongoose.Types.ObjectId(restaurantId);

    // Get commission rate
    const commissionSetting = await Setting.findOne({ key: 'default_commission' });
    const commissionRate = (commissionSetting?.value as number) || 15;

    // Calculate total earnings from completed orders
    const earningsResult = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          status: 'delivered',
          paymentStatus: 'paid',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$subtotal' },
        },
      },
    ]);

    const totalRevenue = earningsResult[0]?.total || 0;
    const totalEarnings = Math.round(totalRevenue * (1 - commissionRate / 100));

    // Calculate completed payouts
    const completedPayoutsResult = await Payout.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          status: 'completed',
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const withdrawn = completedPayoutsResult[0]?.total || 0;

    // Calculate pending payouts
    const pendingPayoutsResult = await Payout.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          status: { $in: ['pending', 'processing'] },
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const pending = pendingPayoutsResult[0]?.total || 0;

    return {
      totalEarnings,
      withdrawn,
      pending,
      available: totalEarnings - withdrawn - pending,
    };
  }

  /**
   * Get payout history for a restaurant
   */
  async getPayouts(
    restaurantId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<PaginatedPayouts> {
    const skip = (page - 1) * limit;

    const [payouts, total] = await Promise.all([
      Payout.find({ restaurantId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Payout.countDocuments({ restaurantId }),
    ]);

    return {
      payouts: payouts as IPayout[],
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get payout by ID
   */
  async getPayoutById(payoutId: string, restaurantId?: string): Promise<IPayout> {
    const query: Record<string, unknown> = { _id: payoutId };
    if (restaurantId) {
      query.restaurantId = restaurantId;
    }

    const payout = await Payout.findOne(query).populate('restaurant', 'name nameAr');

    if (!payout) {
      throw new NotFoundError('طلب السحب غير موجود');
    }

    return payout;
  }

  /**
   * Update payout status (admin only)
   */
  async updatePayoutStatus(
    payoutId: string,
    status: 'processing' | 'completed' | 'rejected',
    adminId: string,
    adminNotes?: string
  ): Promise<IPayout> {
    const payout = await Payout.findById(payoutId).populate('restaurantId', 'userId name');

    if (!payout) {
      throw new NotFoundError('طلب السحب غير موجود');
    }

    if (payout.status === 'completed' || payout.status === 'rejected') {
      throw new BadRequestError('لا يمكن تعديل طلب سحب مكتمل أو مرفوض');
    }

    payout.status = status;
    payout.adminNotes = adminNotes;

    if (status === 'completed' || status === 'rejected') {
      payout.processedAt = new Date();
      payout.processedBy = new Types.ObjectId(adminId);
    }

    await payout.save();

    // Update transaction status (find by notes containing payout ID)
    await Transaction.updateOne(
      { notes: { $regex: payout._id.toString() }, type: 'restaurant_payout' },
      { status: status === 'completed' ? 'completed' : status === 'rejected' ? 'failed' : 'pending' }
    );

    // Notify restaurant owner
    const restaurant = payout.restaurantId as unknown as { userId: Types.ObjectId; name: string };
    if (restaurant.userId) {
      const statusMessages = {
        processing: 'طلب السحب قيد المعالجة',
        completed: 'تم تحويل المبلغ بنجاح',
        rejected: 'تم رفض طلب السحب',
      };

      emitToUser(restaurant.userId.toString(), 'payout:status', {
        payoutId: payout._id,
        reference: payout.reference,
        status,
        amount: payout.amount,
        message: statusMessages[status],
      });
    }

    return payout;
  }

  /**
   * Get all payouts (admin)
   */
  async getAllPayouts(options: {
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<PaginatedPayouts> {
    const { status, page = 1, limit = 20 } = options;
    const skip = (page - 1) * limit;

    const query: Record<string, unknown> = {};
    if (status) {
      query.status = status;
    }

    const [payouts, total] = await Promise.all([
      Payout.find(query)
        .populate('restaurantId', 'name nameAr')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      Payout.countDocuments(query),
    ]);

    return {
      payouts: payouts as IPayout[],
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    };
  }
}

export const payoutService = new PayoutService();
export default payoutService;
