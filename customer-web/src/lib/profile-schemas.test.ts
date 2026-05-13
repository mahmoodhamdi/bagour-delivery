import { describe, expect, it } from "vitest";

import { addressFormSchema, changePasswordSchema, profileEditSchema } from "./profile-schemas";

describe("profileEditSchema", () => {
  it("accepts a valid update", () => {
    expect(profileEditSchema.safeParse({ name: "Mahmoud", phone: "01012345678" }).success).toBe(
      true,
    );
  });

  it("rejects short names", () => {
    expect(profileEditSchema.safeParse({ name: "M", phone: "01012345678" }).success).toBe(false);
  });

  it("rejects bad phones", () => {
    expect(profileEditSchema.safeParse({ name: "Mahmoud", phone: "+1 555 0100" }).success).toBe(
      false,
    );
  });
});

describe("changePasswordSchema", () => {
  it("accepts a valid change", () => {
    expect(
      changePasswordSchema.safeParse({
        currentPassword: "old-pw-1",
        newPassword: "new-pw-12345",
        confirmPassword: "new-pw-12345",
      }).success,
    ).toBe(true);
  });

  it("rejects mismatched new + confirm", () => {
    const r = changePasswordSchema.safeParse({
      currentPassword: "old-pw-1",
      newPassword: "new-pw-12345",
      confirmPassword: "other",
    });
    expect(r.success).toBe(false);
  });

  it("rejects when new == current", () => {
    const r = changePasswordSchema.safeParse({
      currentPassword: "same-pw-12",
      newPassword: "same-pw-12",
      confirmPassword: "same-pw-12",
    });
    expect(r.success).toBe(false);
    if (!r.success) {
      expect(r.error.issues.find((i) => i.path[0] === "newPassword")?.message).toBe(
        "Profile.errors.newPasswordMustDiffer",
      );
    }
  });
});

describe("addressFormSchema", () => {
  it("accepts a minimal address", () => {
    expect(
      addressFormSchema.safeParse({ street: "Main", area: "Bagour", city: "Monufia" }).success,
    ).toBe(true);
  });

  it("rejects empty street", () => {
    expect(
      addressFormSchema.safeParse({ street: "", area: "Bagour", city: "Monufia" }).success,
    ).toBe(false);
  });

  it("accepts optional lat/lng within range", () => {
    expect(
      addressFormSchema.safeParse({
        street: "Main",
        area: "Bagour",
        city: "Monufia",
        lat: 30.45,
        lng: 30.97,
      }).success,
    ).toBe(true);
  });

  it("rejects out-of-range coordinates", () => {
    expect(
      addressFormSchema.safeParse({
        street: "Main",
        area: "Bagour",
        city: "Monufia",
        lat: 999,
        lng: 999,
      }).success,
    ).toBe(false);
  });
});
