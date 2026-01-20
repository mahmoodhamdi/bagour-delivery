import request from 'supertest';
import express, { ErrorRequestHandler } from 'express';
import { validate } from '../../middleware/validate';
import { createPayoutSchema, updatePayoutStatusSchema } from '../../validators/payout.validator';
import { AppError } from '../../utils/errors';

// Error handler for test app
const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.details,
    });
    return;
  }
  res.status(500).json({
    success: false,
    message: 'Internal server error',
  });
};

// Create a minimal test app for validation testing
const createTestApp = () => {
  const app = express();
  app.use(express.json());

  // Test routes that only test validation
  app.post('/payouts', validate(createPayoutSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.patch('/payouts/:id/status', validate(updatePayoutStatusSchema), (_req, res) => {
    res.json({ success: true });
  });

  // Error handler
  app.use(errorHandler);

  return app;
};

const app = createTestApp();

describe('Payout API Validation', () => {
  describe('POST /payouts', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing amount', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject amount less than minimum (100 EGP)', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 50,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid payment method', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'paypal', // Invalid method
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing accountDetails', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    // Vodafone Cash validation
    it('should accept valid vodafone_cash payout', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should reject vodafone_cash without phone number', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
          accountDetails: {},
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject vodafone_cash with invalid phone format', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '123456789', // Invalid Egyptian phone
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    // InstaPay validation
    it('should accept valid instapay payout', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'instapay',
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    // Bank Transfer validation
    it('should accept valid bank_transfer payout', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 1000,
          method: 'bank_transfer',
          accountDetails: {
            bankName: 'البنك الأهلي المصري',
            accountNumber: '1234567890123456',
            accountHolderName: 'محمد أحمد',
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should reject bank_transfer without bank name', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 1000,
          method: 'bank_transfer',
          accountDetails: {
            accountNumber: '1234567890123456',
            accountHolderName: 'محمد أحمد',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject bank_transfer without account number', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 1000,
          method: 'bank_transfer',
          accountDetails: {
            bankName: 'البنك الأهلي المصري',
            accountHolderName: 'محمد أحمد',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject bank_transfer without account holder name', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 1000,
          method: 'bank_transfer',
          accountDetails: {
            bankName: 'البنك الأهلي المصري',
            accountNumber: '1234567890123456',
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    // Notes validation
    it('should accept payout with optional notes', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
          notes: 'ملاحظات اختيارية',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should reject notes exceeding 500 characters', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 500,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
          notes: 'a'.repeat(501),
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    // Edge cases
    it('should accept minimum amount (100 EGP)', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 100,
          method: 'vodafone_cash',
          accountDetails: {
            phoneNumber: '01012345678',
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept large amount', async () => {
      const response = await request(app)
        .post('/payouts')
        .send({
          amount: 100000,
          method: 'bank_transfer',
          accountDetails: {
            bankName: 'CIB',
            accountNumber: '1234567890123456',
            accountHolderName: 'شركة المطعم',
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('PATCH /payouts/:id/status', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing status', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          adminNotes: 'some notes',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid status', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'invalid_status',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid status - processing', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'processing',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept valid status - completed', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'completed',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept valid status - rejected', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'rejected',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept status with optional adminNotes', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'completed',
          adminNotes: 'تم التحويل بنجاح',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should reject adminNotes exceeding 500 characters', async () => {
      const response = await request(app)
        .patch('/payouts/123/status')
        .send({
          status: 'rejected',
          adminNotes: 'a'.repeat(501),
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });
});
