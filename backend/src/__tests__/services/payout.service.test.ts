import { payoutService } from '../../services/payout.service';
import { Payout } from '../../models/Payout';
import { Restaurant } from '../../models/Restaurant';
import { Order } from '../../models/Order';
import { Transaction } from '../../models/Transaction';
import { Setting } from '../../models/Setting';
import { ConflictError, BadRequestError, NotFoundError } from '../../utils/errors';

// Mock the models
jest.mock('../../models/Payout');
jest.mock('../../models/Restaurant');
jest.mock('../../models/Order');
jest.mock('../../models/Transaction');
jest.mock('../../models/Setting');
jest.mock('../../config/socket', () => ({
  getIO: jest.fn(() => ({
    to: jest.fn(() => ({
      emit: jest.fn(),
    })),
  })),
  emitToUser: jest.fn(),
}));

describe('PayoutService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createPayout', () => {
    const validInput = {
      amount: 500,
      method: 'vodafone_cash' as const,
      accountDetails: {
        phoneNumber: '01012345678',
      },
      notes: 'Test payout',
    };

    const mockRestaurant = {
      _id: '507f1f77bcf86cd799439011',
      name: 'Test Restaurant',
      userId: '507f1f77bcf86cd799439012',
    };

    it('should create payout request successfully', async () => {
      // No pending payouts
      (Payout.findOne as jest.Mock).mockResolvedValue(null);
      // Restaurant exists
      (Restaurant.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockRestaurant),
      });
      // Setting for commission
      (Setting.findOne as jest.Mock).mockResolvedValue({ value: 15 });
      // Order aggregate for balance
      (Order.aggregate as jest.Mock).mockResolvedValue([{ total: 10000 }]);
      // Payout aggregate for completed payouts
      (Payout.aggregate as jest.Mock).mockResolvedValue([{ total: 0 }]);
      // Transaction create
      (Transaction.create as jest.Mock).mockResolvedValue({});

      const mockSave = jest.fn().mockResolvedValue({
        ...validInput,
        _id: '507f1f77bcf86cd799439013',
        reference: 'PAY-260120-0001',
        status: 'pending',
      });

      (Payout as unknown as jest.Mock).mockImplementation(() => ({
        ...validInput,
        save: mockSave,
      }));

      const result = await payoutService.createPayout(mockRestaurant._id, validInput);

      expect(Payout.findOne).toHaveBeenCalled();
      expect(mockSave).toHaveBeenCalled();
    });

    it('should throw ConflictError if pending payout exists', async () => {
      (Payout.findOne as jest.Mock).mockResolvedValue({
        _id: '507f1f77bcf86cd799439014',
        status: 'pending',
      });

      await expect(
        payoutService.createPayout('507f1f77bcf86cd799439011', validInput)
      ).rejects.toThrow(ConflictError);
    });

    it('should throw NotFoundError if restaurant not found', async () => {
      (Payout.findOne as jest.Mock).mockResolvedValue(null);
      (Restaurant.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });

      await expect(
        payoutService.createPayout('507f1f77bcf86cd799439011', validInput)
      ).rejects.toThrow(NotFoundError);
    });

    it('should throw BadRequestError if amount exceeds balance', async () => {
      (Payout.findOne as jest.Mock).mockResolvedValue(null);
      (Restaurant.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockRestaurant),
      });
      (Setting.findOne as jest.Mock).mockResolvedValue({ value: 15 });
      (Order.aggregate as jest.Mock).mockResolvedValue([{ total: 100 }]); // Only 85 EGP after commission
      (Payout.aggregate as jest.Mock).mockResolvedValue([{ total: 0 }]);

      await expect(
        payoutService.createPayout(mockRestaurant._id, { ...validInput, amount: 500 })
      ).rejects.toThrow(BadRequestError);
    });
  });

  describe('getBalance', () => {
    it('should calculate balance correctly', async () => {
      (Setting.findOne as jest.Mock).mockResolvedValue({ value: 15 });
      (Order.aggregate as jest.Mock).mockResolvedValue([{ total: 10000 }]);
      (Payout.aggregate as jest.Mock)
        .mockResolvedValueOnce([{ total: 2000 }]) // completed payouts
        .mockResolvedValueOnce([{ total: 500 }]); // pending payouts

      const result = await payoutService.getBalance('507f1f77bcf86cd799439011');

      // Expected: 10000 * 0.85 = 8500 total earnings
      // Available: 8500 - 2000 - 500 = 6000
      expect(result.totalEarnings).toBe(8500);
      expect(result.withdrawn).toBe(2000);
      expect(result.pending).toBe(500);
      expect(result.available).toBe(6000);
    });

    it('should handle no orders', async () => {
      (Setting.findOne as jest.Mock).mockResolvedValue({ value: 15 });
      (Order.aggregate as jest.Mock).mockResolvedValue([]);
      (Payout.aggregate as jest.Mock)
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([]);

      const result = await payoutService.getBalance('507f1f77bcf86cd799439011');

      expect(result.totalEarnings).toBe(0);
      expect(result.available).toBe(0);
    });

    it('should use default commission if setting not found', async () => {
      (Setting.findOne as jest.Mock).mockResolvedValue(null);
      (Order.aggregate as jest.Mock).mockResolvedValue([{ total: 1000 }]);
      (Payout.aggregate as jest.Mock)
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([]);

      const result = await payoutService.getBalance('507f1f77bcf86cd799439011');

      // Default 15% commission: 1000 * 0.85 = 850
      expect(result.totalEarnings).toBe(850);
    });
  });

  describe('getPayouts', () => {
    it('should return paginated payouts', async () => {
      const mockPayouts = [
        { _id: '1', amount: 500, status: 'completed' },
        { _id: '2', amount: 300, status: 'pending' },
      ];

      (Payout.find as jest.Mock).mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(mockPayouts),
      });
      (Payout.countDocuments as jest.Mock).mockResolvedValue(10);

      const result = await payoutService.getPayouts('507f1f77bcf86cd799439011', 1, 10);

      expect(result.payouts).toHaveLength(2);
      expect(result.pagination.total).toBe(10);
      expect(result.pagination.pages).toBe(1);
    });

    it('should calculate pages correctly', async () => {
      (Payout.find as jest.Mock).mockReturnValue({
        sort: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue([]),
      });
      (Payout.countDocuments as jest.Mock).mockResolvedValue(25);

      const result = await payoutService.getPayouts('507f1f77bcf86cd799439011', 1, 10);

      expect(result.pagination.pages).toBe(3);
    });
  });

  describe('getPayoutById', () => {
    it('should return payout when found', async () => {
      const mockPayout = { _id: '507f1f77bcf86cd799439013', amount: 500 };
      (Payout.findOne as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockPayout),
      });

      const result = await payoutService.getPayoutById('507f1f77bcf86cd799439013');

      expect(result).toEqual(mockPayout);
    });

    it('should throw NotFoundError when payout not found', async () => {
      (Payout.findOne as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });

      await expect(
        payoutService.getPayoutById('507f1f77bcf86cd799439013')
      ).rejects.toThrow(NotFoundError);
    });
  });

  describe('updatePayoutStatus', () => {
    const mockPayout = {
      _id: '507f1f77bcf86cd799439013',
      amount: 500,
      status: 'pending',
      restaurantId: {
        userId: '507f1f77bcf86cd799439012',
        name: 'Test Restaurant',
      },
      reference: 'PAY-260120-0001',
      save: jest.fn(),
    };

    it('should update status to completed', async () => {
      (Payout.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({ ...mockPayout }),
      });
      (Transaction.updateOne as jest.Mock).mockResolvedValue({});

      const result = await payoutService.updatePayoutStatus(
        '507f1f77bcf86cd799439013',
        'completed',
        '507f1f77bcf86cd799439014'
      );

      expect(result.status).toBe('completed');
      expect(result.processedAt).toBeDefined();
    });

    it('should throw NotFoundError when payout not found', async () => {
      (Payout.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });

      await expect(
        payoutService.updatePayoutStatus(
          '507f1f77bcf86cd799439013',
          'completed',
          '507f1f77bcf86cd799439014'
        )
      ).rejects.toThrow(NotFoundError);
    });

    it('should throw BadRequestError for already completed payout', async () => {
      (Payout.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({
          ...mockPayout,
          status: 'completed',
        }),
      });

      await expect(
        payoutService.updatePayoutStatus(
          '507f1f77bcf86cd799439013',
          'processing',
          '507f1f77bcf86cd799439014'
        )
      ).rejects.toThrow(BadRequestError);
    });
  });
});
