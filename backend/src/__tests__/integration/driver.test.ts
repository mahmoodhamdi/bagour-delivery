import request from 'supertest';
import express, { ErrorRequestHandler } from 'express';
import { validate } from '../../middleware/validate';
import {
  updateLocationSchema,
  toggleOnlineSchema,
  updateOrderStatusSchema,
  rejectOrderSchema,
} from '../../validators/driver.validator';
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
  app.put('/location', validate(updateLocationSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.post('/toggle-online', validate(toggleOnlineSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.put('/orders/:id/status', validate(updateOrderStatusSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.put('/orders/:id/reject', validate(rejectOrderSchema), (_req, res) => {
    res.json({ success: true });
  });

  // Error handler
  app.use(errorHandler);

  return app;
};

const app = createTestApp();

describe('Driver API Validation', () => {
  describe('PUT /location', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .put('/location')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid latitude', async () => {
      const response = await request(app)
        .put('/location')
        .send({
          latitude: 100, // Invalid: must be between -90 and 90
          longitude: 31.2357,
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid longitude', async () => {
      const response = await request(app)
        .put('/location')
        .send({
          latitude: 30.0444,
          longitude: 200, // Invalid: must be between -180 and 180
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid location data', async () => {
      const response = await request(app)
        .put('/location')
        .send({
          latitude: 30.0444,
          longitude: 31.2357,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('POST /toggle-online', () => {
    it('should reject missing isOnline', async () => {
      const response = await request(app)
        .post('/toggle-online')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject non-boolean isOnline', async () => {
      const response = await request(app)
        .post('/toggle-online')
        .send({
          isOnline: 'yes',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid toggle data', async () => {
      const response = await request(app)
        .post('/toggle-online')
        .send({
          isOnline: true,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('PUT /orders/:id/status', () => {
    it('should reject missing status', async () => {
      const response = await request(app)
        .put('/orders/123/status')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid status', async () => {
      const response = await request(app)
        .put('/orders/123/status')
        .send({
          status: 'invalid_status',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid status - picked_up', async () => {
      const response = await request(app)
        .put('/orders/123/status')
        .send({
          status: 'picked_up',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept valid status - on_the_way', async () => {
      const response = await request(app)
        .put('/orders/123/status')
        .send({
          status: 'on_the_way',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept valid status - delivered', async () => {
      const response = await request(app)
        .put('/orders/123/status')
        .send({
          status: 'delivered',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('PUT /orders/:id/reject', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing reason', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          otherField: 'value',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject short reason (less than 10 chars)', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'short',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject reason exceeding 500 characters', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'a'.repeat(501),
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid rejection reason in Arabic', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'المطعم بعيد جداً عن موقعي الحالي',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept valid rejection reason in English', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'The restaurant is too far from my current location',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept reason at exactly 10 characters', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'abcdefghij', // exactly 10 characters
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should accept reason at exactly 500 characters', async () => {
      const response = await request(app)
        .put('/orders/123/reject')
        .send({
          reason: 'a'.repeat(500),
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });
});
