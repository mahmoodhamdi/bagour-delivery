import { describe, expect, it } from "vitest";

import {
  forgotPasswordFormSchema,
  loginFormSchema,
  otpFormSchema,
  registerFormSchema,
  resetPasswordFormSchema,
} from "./auth-schemas";

describe("loginFormSchema", () => {
  it("rejects missing email", () => {
    const r = loginFormSchema.safeParse({ email: "", password: "12345678" });
    expect(r.success).toBe(false);
    if (!r.success) {
      expect(r.error.issues[0]?.message).toBe("Auth.errors.emailRequired");
    }
  });

  it("rejects short password", () => {
    const r = loginFormSchema.safeParse({ email: "a@b.com", password: "123" });
    expect(r.success).toBe(false);
    if (!r.success) {
      expect(r.error.issues[0]?.message).toBe("Auth.errors.passwordTooShort");
    }
  });

  it("accepts a valid input", () => {
    const r = loginFormSchema.safeParse({ email: "a@b.com", password: "12345678" });
    expect(r.success).toBe(true);
  });
});

describe("registerFormSchema", () => {
  const good = {
    name: "Captain",
    email: "c@d.com",
    phone: "01012345678",
    password: "12345678",
    confirmPassword: "12345678",
    acceptTerms: true,
  };

  it("accepts a complete driver registration", () => {
    expect(registerFormSchema.safeParse(good).success).toBe(true);
  });

  it("rejects mismatched passwords", () => {
    const r = registerFormSchema.safeParse({
      ...good,
      confirmPassword: "different8",
    });
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.find((i) => i.path.includes("confirmPassword"))?.message;
      expect(msg).toBe("Auth.errors.passwordsDontMatch");
    }
  });

  it("rejects when terms not accepted", () => {
    const r = registerFormSchema.safeParse({ ...good, acceptTerms: false });
    expect(r.success).toBe(false);
  });

  it("rejects an Egyptian-looking phone with the wrong prefix", () => {
    const r = registerFormSchema.safeParse({ ...good, phone: "00112345678" });
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.find((i) => i.path.includes("phone"))?.message;
      expect(msg).toBe("Auth.errors.invalidPhone");
    }
  });
});

describe("otpFormSchema", () => {
  it("requires 6 digits", () => {
    expect(otpFormSchema.safeParse({ otp: "123" }).success).toBe(false);
    expect(otpFormSchema.safeParse({ otp: "12345a" }).success).toBe(false);
    expect(otpFormSchema.safeParse({ otp: "123456" }).success).toBe(true);
  });
});

describe("forgotPasswordFormSchema", () => {
  it("requires a valid email", () => {
    expect(forgotPasswordFormSchema.safeParse({ email: "" }).success).toBe(false);
    expect(forgotPasswordFormSchema.safeParse({ email: "not-email" }).success).toBe(false);
    expect(forgotPasswordFormSchema.safeParse({ email: "a@b.com" }).success).toBe(true);
  });
});

describe("resetPasswordFormSchema", () => {
  it("enforces password equality + 6-digit OTP", () => {
    const r = resetPasswordFormSchema.safeParse({
      email: "a@b.com",
      otp: "123456",
      newPassword: "12345678",
      confirmPassword: "12345678",
    });
    expect(r.success).toBe(true);

    const bad = resetPasswordFormSchema.safeParse({
      email: "a@b.com",
      otp: "12345",
      newPassword: "12345678",
      confirmPassword: "different",
    });
    expect(bad.success).toBe(false);
  });
});
