import request from 'supertest';
import express, { ErrorRequestHandler } from 'express';
import { validate } from '../../middleware/validate';
import {
  customerRegisterSchema,
  loginSchema,
  forgotPasswordSchema,
  verifyOtpSchema,
  refreshTokenSchema,
} from '../../validators/auth.validator';
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
  app.post('/customer/register', validate(customerRegisterSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.post('/login', validate(loginSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.post('/forgot-password', validate(forgotPasswordSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.post('/verify-otp', validate(verifyOtpSchema), (_req, res) => {
    res.json({ success: true });
  });

  app.post('/refresh-token', validate(refreshTokenSchema), (_req, res) => {
    res.json({ success: true });
  });

  // Error handler
  app.use(errorHandler);

  return app;
};

const app = createTestApp();

describe('Auth API Validation', () => {
  describe('POST /customer/register', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid email format', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({
          name: 'Test User',
          email: 'invalid-email',
          phone: '01012345678',
          password: 'password123',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid phone number', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({
          name: 'Test User',
          email: 'test@example.com',
          phone: '123456789',
          password: 'password123',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject short password', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({
          name: 'Test User',
          email: 'test@example.com',
          phone: '01012345678',
          password: 'short',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing name', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({
          email: 'test@example.com',
          phone: '01012345678',
          password: 'password123',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid registration data', async () => {
      const response = await request(app)
        .post('/customer/register')
        .send({
          name: 'Test User',
          email: 'test@example.com',
          phone: '01012345678',
          password: 'password123',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('POST /login', () => {
    it('should reject empty body', async () => {
      const response = await request(app)
        .post('/login')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject missing password', async () => {
      const response = await request(app)
        .post('/login')
        .send({
          email: 'test@example.com',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid email format', async () => {
      const response = await request(app)
        .post('/login')
        .send({
          email: 'not-an-email',
          password: 'password123',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid login data', async () => {
      const response = await request(app)
        .post('/login')
        .send({
          email: 'test@example.com',
          password: 'password123',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('POST /forgot-password', () => {
    it('should reject missing email', async () => {
      const response = await request(app)
        .post('/forgot-password')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid email', async () => {
      const response = await request(app)
        .post('/forgot-password')
        .send({
          email: 'invalid',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid email', async () => {
      const response = await request(app)
        .post('/forgot-password')
        .send({
          email: 'test@example.com',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('POST /verify-otp', () => {
    it('should reject without phone or email', async () => {
      const response = await request(app)
        .post('/verify-otp')
        .send({
          otp: '123456',
          type: 'phone_verification',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should reject invalid OTP format', async () => {
      const response = await request(app)
        .post('/verify-otp')
        .send({
          phone: '01012345678',
          otp: '12345', // 5 digits instead of 6
          type: 'phone_verification',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid OTP data', async () => {
      const response = await request(app)
        .post('/verify-otp')
        .send({
          phone: '01012345678',
          otp: '123456',
          type: 'phone_verification',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('POST /refresh-token', () => {
    it('should reject missing refresh token', async () => {
      const response = await request(app)
        .post('/refresh-token')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should accept valid refresh token', async () => {
      const response = await request(app)
        .post('/refresh-token')
        .send({
          refreshToken: 'some-valid-token',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });
});
