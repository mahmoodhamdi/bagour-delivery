import {
  customerRegisterSchema,
  loginSchema,
  phoneLoginSchema,
  verifyOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  changePasswordSchema,
  driverRegisterSchema,
} from '../../validators/auth.validator';

describe('Auth Validators', () => {
  describe('customerRegisterSchema', () => {
    const validData = {
      name: 'Ahmed Mohamed',
      email: 'ahmed@example.com',
      phone: '01012345678',
      password: 'password123',
    };

    it('should validate correct customer data', () => {
      const { error } = customerRegisterSchema.validate(validData);
      expect(error).toBeUndefined();
    });

    it('should reject missing name', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        name: undefined,
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('الاسم');
    });

    it('should reject short name', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        name: 'A',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('حرفين');
    });

    it('should reject invalid email', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        email: 'not-an-email',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('البريد الإلكتروني');
    });

    it('should reject invalid phone number', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        phone: '123456789',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('الهاتف');
    });

    it('should validate Egyptian phone numbers starting with 010, 011, 012, 015', () => {
      const validPhones = ['01012345678', '01112345678', '01212345678', '01512345678'];

      validPhones.forEach((phone) => {
        const { error } = customerRegisterSchema.validate({ ...validData, phone });
        expect(error).toBeUndefined();
      });
    });

    it('should reject invalid Egyptian phone prefixes', () => {
      const invalidPhones = ['01312345678', '01612345678', '02012345678'];

      invalidPhones.forEach((phone) => {
        const { error } = customerRegisterSchema.validate({ ...validData, phone });
        expect(error).toBeDefined();
      });
    });

    it('should reject short password', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        password: '1234567',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('8');
    });

    it('should allow optional referralCode', () => {
      const { error } = customerRegisterSchema.validate({
        ...validData,
        referralCode: 'REF123',
      });
      expect(error).toBeUndefined();
    });
  });

  describe('loginSchema', () => {
    it('should validate correct login data', () => {
      const { error } = loginSchema.validate({
        email: 'test@example.com',
        password: 'password123',
      });
      expect(error).toBeUndefined();
    });

    it('should reject missing email', () => {
      const { error } = loginSchema.validate({
        password: 'password123',
      });
      expect(error).toBeDefined();
    });

    it('should reject missing password', () => {
      const { error } = loginSchema.validate({
        email: 'test@example.com',
      });
      expect(error).toBeDefined();
    });

    it('should reject invalid email format', () => {
      const { error } = loginSchema.validate({
        email: 'invalid-email',
        password: 'password123',
      });
      expect(error).toBeDefined();
    });
  });

  describe('phoneLoginSchema', () => {
    it('should validate valid phone number', () => {
      const { error } = phoneLoginSchema.validate({
        phone: '01012345678',
      });
      expect(error).toBeUndefined();
    });

    it('should reject invalid phone number', () => {
      const { error } = phoneLoginSchema.validate({
        phone: '1234567890',
      });
      expect(error).toBeDefined();
    });
  });

  describe('verifyOtpSchema', () => {
    it('should validate with phone and OTP', () => {
      const { error } = verifyOtpSchema.validate({
        phone: '01012345678',
        otp: '123456',
        type: 'phone_verification',
      });
      expect(error).toBeUndefined();
    });

    it('should validate with email and OTP', () => {
      const { error } = verifyOtpSchema.validate({
        email: 'test@example.com',
        otp: '123456',
        type: 'email_verification',
      });
      expect(error).toBeUndefined();
    });

    it('should reject without phone or email', () => {
      const { error } = verifyOtpSchema.validate({
        otp: '123456',
        type: 'phone_verification',
      });
      expect(error).toBeDefined();
    });

    it('should reject invalid OTP format', () => {
      const { error } = verifyOtpSchema.validate({
        phone: '01012345678',
        otp: '12345', // 5 digits instead of 6
        type: 'phone_verification',
      });
      expect(error).toBeDefined();
    });

    it('should reject non-numeric OTP', () => {
      const { error } = verifyOtpSchema.validate({
        phone: '01012345678',
        otp: 'abcdef',
        type: 'phone_verification',
      });
      expect(error).toBeDefined();
    });
  });

  describe('forgotPasswordSchema', () => {
    it('should validate correct email', () => {
      const { error } = forgotPasswordSchema.validate({
        email: 'test@example.com',
      });
      expect(error).toBeUndefined();
    });

    it('should reject invalid email', () => {
      const { error } = forgotPasswordSchema.validate({
        email: 'invalid',
      });
      expect(error).toBeDefined();
    });
  });

  describe('resetPasswordSchema', () => {
    it('should validate correct reset data', () => {
      const { error } = resetPasswordSchema.validate({
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'newpassword123',
        confirmPassword: 'newpassword123',
      });
      expect(error).toBeUndefined();
    });

    it('should reject mismatched passwords', () => {
      const { error } = resetPasswordSchema.validate({
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'newpassword123',
        confirmPassword: 'differentpassword',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('غير متطابقة');
    });

    it('should reject short password', () => {
      const { error } = resetPasswordSchema.validate({
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'short',
        confirmPassword: 'short',
      });
      expect(error).toBeDefined();
    });
  });

  describe('changePasswordSchema', () => {
    it('should validate correct password change data', () => {
      const { error } = changePasswordSchema.validate({
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
        confirmPassword: 'newpassword123',
      });
      expect(error).toBeUndefined();
    });

    it('should reject mismatched passwords', () => {
      const { error } = changePasswordSchema.validate({
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
        confirmPassword: 'differentpassword',
      });
      expect(error).toBeDefined();
    });

    it('should reject missing current password', () => {
      const { error } = changePasswordSchema.validate({
        newPassword: 'newpassword123',
        confirmPassword: 'newpassword123',
      });
      expect(error).toBeDefined();
    });
  });

  describe('driverRegisterSchema', () => {
    const validDriver = {
      name: 'Mohamed Ali',
      email: 'driver@example.com',
      phone: '01012345678',
      password: 'password123',
      nationalId: '29801011234567',
      vehicleType: 'motorcycle',
      vehiclePlateNumber: 'ABC123',
      licenseNumber: 'DL123456',
      licenseExpiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year from now
    };

    it('should validate correct driver data', () => {
      const { error } = driverRegisterSchema.validate(validDriver);
      expect(error).toBeUndefined();
    });

    it('should reject invalid national ID (not 14 digits)', () => {
      const { error } = driverRegisterSchema.validate({
        ...validDriver,
        nationalId: '1234567890',
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('14');
    });

    it('should reject invalid vehicle type', () => {
      const { error } = driverRegisterSchema.validate({
        ...validDriver,
        vehicleType: 'plane',
      });
      expect(error).toBeDefined();
    });

    it('should accept valid vehicle types', () => {
      const vehicleTypes = ['motorcycle', 'bicycle', 'car'];

      vehicleTypes.forEach((vehicleType) => {
        const { error } = driverRegisterSchema.validate({ ...validDriver, vehicleType });
        expect(error).toBeUndefined();
      });
    });

    it('should reject expired license', () => {
      const { error } = driverRegisterSchema.validate({
        ...validDriver,
        licenseExpiryDate: new Date('2020-01-01'),
      });
      expect(error).toBeDefined();
      expect(error?.details[0].message).toContain('منتهية');
    });
  });
});
