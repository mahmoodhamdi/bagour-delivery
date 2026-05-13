import { describe, expect, it } from "vitest";

import {
  forgotPasswordFormSchema,
  loginFormSchema,
  otpFormSchema,
  registerFormSchema,
  resetPasswordFormSchema,
} from "./auth-schemas";

describe("loginFormSchema", () => {
  it("accepts a valid payload", () => {
    expect(loginFormSchema.safeParse({ email: "a@b.co", password: "secret123" }).success).toBe(
      true,
    );
  });

  it("emits i18n keys for invalid fields", () => {
    const r = loginFormSchema.safeParse({ email: "", password: "1" });
    expect(r.success).toBe(false);
    if (!r.success) {
      const messages = r.error.issues.map((i) => i.message);
      expect(messages).toContain("Auth.errors.emailRequired");
      expect(messages).toContain("Auth.errors.passwordTooShort");
    }
  });
});

describe("registerFormSchema", () => {
  const valid = {
    name: "Mahmoud",
    email: "m@b.co",
    phone: "01012345678",
    password: "secret123",
    confirmPassword: "secret123",
    role: "customer" as const,
    acceptTerms: true as const,
  };

  it("accepts a valid payload", () => {
    expect(registerFormSchema.safeParse(valid).success).toBe(true);
  });

  it("rejects non-Egyptian phone numbers", () => {
    const r = registerFormSchema.safeParse({ ...valid, phone: "+1 555 0100" });
    expect(r.success).toBe(false);
    if (!r.success) {
      expect(r.error.issues.find((i) => i.path[0] === "phone")?.message).toBe(
        "Auth.errors.invalidPhone",
      );
    }
  });

  it("rejects mismatched passwords", () => {
    const r = registerFormSchema.safeParse({ ...valid, confirmPassword: "different1" });
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.find((i) => i.path[0] === "confirmPassword")?.message;
      expect(msg).toBe("Auth.errors.passwordsDontMatch");
    }
  });

  it("requires terms acceptance", () => {
    const r = registerFormSchema.safeParse({ ...valid, acceptTerms: false });
    expect(r.success).toBe(false);
  });
});

describe("otpFormSchema", () => {
  it("requires exactly 6 digits", () => {
    expect(otpFormSchema.safeParse({ otp: "123456" }).success).toBe(true);
    expect(otpFormSchema.safeParse({ otp: "12345" }).success).toBe(false);
    expect(otpFormSchema.safeParse({ otp: "12345a" }).success).toBe(false);
    expect(otpFormSchema.safeParse({ otp: "1234567" }).success).toBe(false);
  });
});

describe("forgotPasswordFormSchema", () => {
  it("accepts a valid email", () => {
    expect(forgotPasswordFormSchema.safeParse({ email: "a@b.co" }).success).toBe(true);
  });

  it("rejects empty", () => {
    expect(forgotPasswordFormSchema.safeParse({ email: "" }).success).toBe(false);
  });
});

describe("resetPasswordFormSchema", () => {
  const valid = {
    email: "a@b.co",
    otp: "123456",
    newPassword: "newpass123",
    confirmPassword: "newpass123",
  };

  it("accepts a valid payload", () => {
    expect(resetPasswordFormSchema.safeParse(valid).success).toBe(true);
  });

  it("rejects mismatched passwords with i18n key", () => {
    const r = resetPasswordFormSchema.safeParse({ ...valid, confirmPassword: "other" });
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = r.error.issues.find((i) => i.path[0] === "confirmPassword")?.message;
      expect(msg).toBe("Auth.errors.passwordsDontMatch");
    }
  });
});
