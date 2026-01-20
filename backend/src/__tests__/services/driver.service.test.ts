import { driverService } from '../../services/driver.service';
import { Driver } from '../../models/Driver';
import { Order } from '../../models/Order';
import { NotFoundError, BadRequestError, ForbiddenError } from '../../utils/errors';

// Mock the models
jest.mock('../../models/Driver');
jest.mock('../../models/Order');
jest.mock('../../services/notification.service', () => ({
  notificationService: {
    createAndSendNotification: jest.fn().mockResolvedValue({}),
  },
}));
jest.mock('../../config/socket', () => ({
  getIO: jest.fn(() => ({
    to: jest.fn(() => ({
      emit: jest.fn(),
    })),
  })),
  emitToRestaurant: jest.fn(),
}));

describe('DriverService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rejectOrder', () => {
    const mockDriverId = '507f1f77bcf86cd799439011';
    const mockOrderId = '507f1f77bcf86cd799439012';
    const mockRestaurantId = {
      _id: '507f1f77bcf86cd799439013',
      userId: '507f1f77bcf86cd799439014',
      name: 'Test Restaurant',
    };

    const mockOrder = {
      _id: mockOrderId,
      orderNumber: 'BAG-260120-0001',
      driverId: { toString: () => mockDriverId },
      restaurantId: mockRestaurantId,
      status: 'picked_up',
      deliveryAddress: {
        name: 'Test Address',
        address: 'Test Street',
        phone: '01012345678',
      },
      total: 150,
      statusHistory: [],
      save: jest.fn().mockResolvedValue(true),
    };

    const mockDriver = {
      _id: mockDriverId,
      currentOrderId: mockOrderId,
      isBusy: true,
      isAvailable: false,
      save: jest.fn().mockResolvedValue(true),
    };

    it('should reject order successfully', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({ ...mockOrder }),
      });
      (Driver.findById as jest.Mock).mockResolvedValue({ ...mockDriver });

      const result = await driverService.rejectOrder(
        mockDriverId,
        mockOrderId,
        'المطعم بعيد جداً عن موقعي'
      );

      expect(result.order).toBeDefined();
      expect(result.rejectedAt).toBeDefined();
      expect(mockOrder.save).toHaveBeenCalled();
    });

    it('should throw NotFoundError if order not found', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(null),
      });

      await expect(
        driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason')
      ).rejects.toThrow(NotFoundError);
    });

    it('should throw ForbiddenError if order not assigned to driver', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({
          ...mockOrder,
          driverId: { toString: () => 'different-driver-id' },
        }),
      });

      await expect(
        driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason')
      ).rejects.toThrow(ForbiddenError);
    });

    it('should throw ForbiddenError if order has no driver', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({
          ...mockOrder,
          driverId: null,
        }),
      });

      await expect(
        driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason')
      ).rejects.toThrow(ForbiddenError);
    });

    it('should throw BadRequestError for delivered orders', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({
          ...mockOrder,
          status: 'delivered',
        }),
      });

      await expect(
        driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason')
      ).rejects.toThrow(BadRequestError);
    });

    it('should throw BadRequestError for cancelled orders', async () => {
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({
          ...mockOrder,
          status: 'cancelled',
        }),
      });

      await expect(
        driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason')
      ).rejects.toThrow(BadRequestError);
    });

    it('should set order status to ready for reassignment', async () => {
      const orderToUpdate = { ...mockOrder, statusHistory: [] };
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(orderToUpdate),
      });
      (Driver.findById as jest.Mock).mockResolvedValue({ ...mockDriver });

      await driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason');

      expect(orderToUpdate.status).toBe('ready');
      expect(orderToUpdate.driverId).toBeUndefined();
    });

    it('should update driver availability', async () => {
      const driverToUpdate = { ...mockDriver };
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue({ ...mockOrder }),
      });
      (Driver.findById as jest.Mock).mockResolvedValue(driverToUpdate);

      await driverService.rejectOrder(mockDriverId, mockOrderId, 'Test reason');

      expect(driverToUpdate.currentOrderId).toBeUndefined();
      expect(driverToUpdate.isBusy).toBe(false);
      expect(driverToUpdate.isAvailable).toBe(true);
      expect(driverToUpdate.save).toHaveBeenCalled();
    });

    it('should add rejection to status history', async () => {
      const orderToUpdate = { ...mockOrder, statusHistory: [] as Array<{ status: string; timestamp: Date; note?: string }> };
      (Order.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(orderToUpdate),
      });
      (Driver.findById as jest.Mock).mockResolvedValue({ ...mockDriver });

      await driverService.rejectOrder(mockDriverId, mockOrderId, 'Test rejection reason');

      expect(orderToUpdate.statusHistory).toHaveLength(1);
      expect(orderToUpdate.statusHistory[0].note).toContain('Test rejection reason');
    });
  });

  describe('getProfile', () => {
    it('should return driver profile when found', async () => {
      const mockDriver = {
        _id: '507f1f77bcf86cd799439011',
        userId: { name: 'Test Driver', email: 'driver@test.com' },
      };

      (Driver.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(mockDriver),
      });

      const result = await driverService.getProfile('507f1f77bcf86cd799439011');

      expect(result).toEqual(mockDriver);
    });

    it('should throw NotFoundError when driver not found', async () => {
      (Driver.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(null),
      });

      await expect(
        driverService.getProfile('507f1f77bcf86cd799439011')
      ).rejects.toThrow(NotFoundError);
    });
  });

  describe('toggleOnlineStatus', () => {
    it('should toggle online status', async () => {
      const mockDriver = {
        _id: '507f1f77bcf86cd799439011',
        isOnline: false,
        isAvailable: false,
        isBusy: false,
        isApproved: true,
        isActive: true,
        status: 'approved',
        save: jest.fn().mockResolvedValue(true),
      };

      (Driver.findById as jest.Mock).mockResolvedValue(mockDriver);

      const result = await driverService.toggleOnlineStatus(
        '507f1f77bcf86cd799439011',
        true
      );

      expect(result.isOnline).toBe(true);
      expect(mockDriver.save).toHaveBeenCalled();
    });

    it('should throw ForbiddenError for unapproved driver', async () => {
      const mockDriver = {
        _id: '507f1f77bcf86cd799439011',
        isApproved: false,
        status: 'pending',
      };

      (Driver.findById as jest.Mock).mockResolvedValue(mockDriver);

      await expect(
        driverService.toggleOnlineStatus('507f1f77bcf86cd799439011', true)
      ).rejects.toThrow(ForbiddenError);
    });

    it('should throw ForbiddenError for inactive driver', async () => {
      const mockDriver = {
        _id: '507f1f77bcf86cd799439011',
        isApproved: true,
        status: 'approved',
        isActive: false,
      };

      (Driver.findById as jest.Mock).mockResolvedValue(mockDriver);

      await expect(
        driverService.toggleOnlineStatus('507f1f77bcf86cd799439011', true)
      ).rejects.toThrow(ForbiddenError);
    });
  });
});
