import { couponService } from '../../services/coupon.service';
import { Coupon } from '../../models/Coupon';
import { Customer } from '../../models/Customer';
import { ConflictError, BadRequestError, NotFoundError } from '../../utils/errors';

// Mock the models
jest.mock('../../models/Coupon');
jest.mock('../../models/Customer');

describe('CouponService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createCoupon', () => {
    const validInput = {
      code: 'TEST10',
      type: 'percentage' as const,
      value: 10,
      validFrom: new Date('2026-01-01'),
      validUntil: new Date('2026-12-31'),
      createdBy: '507f1f77bcf86cd799439011',
    };

    it('should create a coupon successfully', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      const mockSave = jest.fn().mockResolvedValue({
        ...validInput,
        _id: '507f1f77bcf86cd799439012',
        code: 'TEST10',
      });

      (Coupon as unknown as jest.Mock).mockImplementation(() => ({
        ...validInput,
        code: 'TEST10',
        save: mockSave,
      }));

      const result = await couponService.createCoupon(validInput);

      expect(Coupon.findOne).toHaveBeenCalledWith({ code: 'TEST10' });
      expect(mockSave).toHaveBeenCalled();
      expect(result.code).toBe('TEST10');
    });

    it('should throw ConflictError if code already exists', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({ code: 'TEST10' });

      await expect(couponService.createCoupon(validInput)).rejects.toThrow(ConflictError);
    });

    it('should throw BadRequestError if percentage is over 100', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      await expect(
        couponService.createCoupon({ ...validInput, value: 150 })
      ).rejects.toThrow(BadRequestError);
    });

    it('should throw BadRequestError if validUntil is before validFrom', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      await expect(
        couponService.createCoupon({
          ...validInput,
          validFrom: new Date('2026-12-31'),
          validUntil: new Date('2026-01-01'),
        })
      ).rejects.toThrow(BadRequestError);
    });

    it('should convert code to uppercase', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      const mockSave = jest.fn().mockResolvedValue({});
      (Coupon as unknown as jest.Mock).mockImplementation((data) => ({
        ...data,
        save: mockSave,
      }));

      await couponService.createCoupon({ ...validInput, code: 'test10' });

      expect(Coupon.findOne).toHaveBeenCalledWith({ code: 'TEST10' });
    });
  });

  describe('getCouponById', () => {
    it('should return coupon when found', async () => {
      const mockCoupon = { _id: '507f1f77bcf86cd799439012', code: 'TEST10' };
      (Coupon.findById as jest.Mock).mockResolvedValue(mockCoupon);

      const result = await couponService.getCouponById('507f1f77bcf86cd799439012');

      expect(result).toEqual(mockCoupon);
    });

    it('should throw NotFoundError when coupon not found', async () => {
      (Coupon.findById as jest.Mock).mockResolvedValue(null);

      await expect(
        couponService.getCouponById('507f1f77bcf86cd799439012')
      ).rejects.toThrow(NotFoundError);
    });
  });

  describe('getCouponByCode', () => {
    it('should return coupon when found', async () => {
      const mockCoupon = { _id: '507f1f77bcf86cd799439012', code: 'TEST10' };
      (Coupon.findOne as jest.Mock).mockResolvedValue(mockCoupon);

      const result = await couponService.getCouponByCode('test10');

      expect(Coupon.findOne).toHaveBeenCalledWith({ code: 'TEST10' });
      expect(result).toEqual(mockCoupon);
    });

    it('should throw NotFoundError when coupon not found', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      await expect(couponService.getCouponByCode('INVALID')).rejects.toThrow(NotFoundError);
    });
  });

  describe('validateCoupon', () => {
    const mockCoupon = {
      _id: '507f1f77bcf86cd799439012',
      code: 'TEST10',
      type: 'percentage',
      value: 10,
      isActive: true,
      validFrom: new Date('2025-01-01'),
      validUntil: new Date('2027-12-31'),
      minimumOrder: 50,
      perUserLimit: 1,
      totalUsageLimit: 100,
      usedCount: 0,
      usedBy: [],
      restaurantIds: [],
      customerIds: [],
      firstOrderOnly: false,
      maximumDiscount: null,
    };

    it('should return invalid if coupon not found', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(null);

      const result = await couponService.validateCoupon('INVALID', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('غير موجود');
    });

    it('should return invalid if coupon is not active', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({ ...mockCoupon, isActive: false });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('غير مفعل');
    });

    it('should return invalid if coupon has expired', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        validUntil: new Date('2020-01-01'),
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('منتهي الصلاحية');
    });

    it('should return invalid if coupon has not started', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        validFrom: new Date('2030-01-01'),
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('لم يبدأ بعد');
    });

    it('should return invalid if total usage limit reached', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        totalUsageLimit: 10,
        usedCount: 10,
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('الحد الأقصى');
    });

    it('should return invalid if user usage limit reached', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        perUserLimit: 1,
        usedBy: [{ customerId: { toString: () => 'customer1' } }],
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('استخدمت هذا الكود');
    });

    it('should return invalid if subtotal is below minimum order', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        minimumOrder: 100,
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 50);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('الحد الأدنى للطلب');
    });

    it('should return valid with correct discount for percentage coupon', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue(mockCoupon);

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(true);
      expect(result.discount).toBe(10); // 10% of 100
    });

    it('should cap discount at maximum discount', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        value: 50, // 50%
        maximumDiscount: 20,
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(true);
      expect(result.discount).toBe(20); // Capped at maximumDiscount
    });

    it('should return correct discount for fixed amount coupon', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        type: 'fixed',
        value: 25,
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(true);
      expect(result.discount).toBe(25);
    });

    it('should cap fixed discount at subtotal', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        type: 'fixed',
        value: 200,
        minimumOrder: 0,
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(true);
      expect(result.discount).toBe(100); // Capped at subtotal
    });

    it('should return invalid for first order coupon if user has orders', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        firstOrderOnly: true,
      });
      (Customer.findById as jest.Mock).mockResolvedValue({ totalOrders: 1 });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100);

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('الأول');
    });

    it('should return invalid for wrong restaurant', async () => {
      (Coupon.findOne as jest.Mock).mockResolvedValue({
        ...mockCoupon,
        restaurantIds: [{ toString: () => 'restaurant2' }],
      });

      const result = await couponService.validateCoupon('TEST10', 'customer1', 100, 'restaurant1');

      expect(result.isValid).toBe(false);
      expect(result.message).toContain('غير صالح لهذا المطعم');
    });
  });

  describe('deleteCoupon', () => {
    it('should delete coupon if never used', async () => {
      const mockCoupon = {
        _id: '507f1f77bcf86cd799439012',
        usedCount: 0,
        deleteOne: jest.fn().mockResolvedValue({}),
      };
      (Coupon.findById as jest.Mock).mockResolvedValue(mockCoupon);

      await couponService.deleteCoupon('507f1f77bcf86cd799439012');

      expect(mockCoupon.deleteOne).toHaveBeenCalled();
    });

    it('should throw NotFoundError if coupon not found', async () => {
      (Coupon.findById as jest.Mock).mockResolvedValue(null);

      await expect(
        couponService.deleteCoupon('507f1f77bcf86cd799439012')
      ).rejects.toThrow(NotFoundError);
    });

    it('should throw BadRequestError if coupon has been used', async () => {
      (Coupon.findById as jest.Mock).mockResolvedValue({
        _id: '507f1f77bcf86cd799439012',
        usedCount: 5,
      });

      await expect(
        couponService.deleteCoupon('507f1f77bcf86cd799439012')
      ).rejects.toThrow(BadRequestError);
    });
  });

  describe('toggleCouponStatus', () => {
    it('should toggle coupon status', async () => {
      const mockCoupon = {
        _id: '507f1f77bcf86cd799439012',
        isActive: true,
        save: jest.fn().mockResolvedValue({}),
      };
      (Coupon.findById as jest.Mock).mockResolvedValue(mockCoupon);

      await couponService.toggleCouponStatus('507f1f77bcf86cd799439012');

      expect(mockCoupon.isActive).toBe(false);
      expect(mockCoupon.save).toHaveBeenCalled();
    });

    it('should throw NotFoundError if coupon not found', async () => {
      (Coupon.findById as jest.Mock).mockResolvedValue(null);

      await expect(
        couponService.toggleCouponStatus('507f1f77bcf86cd799439012')
      ).rejects.toThrow(NotFoundError);
    });
  });

  describe('generateCouponCode', () => {
    it('should generate code with correct length', () => {
      const code = couponService.generateCouponCode('', 8);
      expect(code.length).toBe(8);
    });

    it('should include prefix', () => {
      const code = couponService.generateCouponCode('PROMO', 4);
      expect(code.startsWith('PROMO')).toBe(true);
      expect(code.length).toBe(9); // PROMO + 4 chars
    });

    it('should generate uppercase codes', () => {
      const code = couponService.generateCouponCode('test', 8);
      expect(code).toBe(code.toUpperCase());
    });
  });
});
