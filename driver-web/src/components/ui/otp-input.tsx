"use client";

import * as React from "react";

import { cn } from "@/lib/utils";

interface OtpInputProps {
  length?: number;
  value: string;
  onChange: (value: string) => void;
  name?: string;
  disabled?: boolean;
  ariaLabel: string;
  autoFocus?: boolean;
  invalid?: boolean;
}

/**
 * Six-cell OTP input. Auto-advances, backspaces, accepts a single paste.
 */
export const OtpInput = React.forwardRef<HTMLDivElement, OtpInputProps>(
  ({ length = 6, value, onChange, name, disabled, ariaLabel, autoFocus, invalid }, ref) => {
    const refs = React.useRef<(HTMLInputElement | null)[]>([]);
    const digits = React.useMemo(() => value.padEnd(length, " ").slice(0, length), [value, length]);

    React.useEffect(() => {
      if (autoFocus) refs.current[0]?.focus();
    }, [autoFocus]);

    const setDigit = (index: number, digit: string) => {
      const next = digits.split("").map((c) => (c === " " ? "" : c));
      next[index] = digit;
      onChange(next.join("").trim());
    };

    const handleChange = (index: number) => (e: React.ChangeEvent<HTMLInputElement>) => {
      const raw = e.target.value.replace(/\D/g, "");
      if (raw.length === 0) {
        setDigit(index, "");
        return;
      }
      if (raw.length > 1) {
        const chars = raw.split("").slice(0, length - index);
        const next = digits.split("").map((c) => (c === " " ? "" : c));
        chars.forEach((c, i) => {
          next[index + i] = c;
        });
        onChange(next.join("").trim());
        refs.current[Math.min(index + chars.length, length - 1)]?.focus();
        return;
      }
      setDigit(index, raw);
      if (index < length - 1) refs.current[index + 1]?.focus();
    };

    const handleKeyDown = (index: number) => (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Backspace") {
        if ((e.currentTarget.value === "" || digits[index] === " ") && index > 0) {
          refs.current[index - 1]?.focus();
          setDigit(index - 1, "");
          e.preventDefault();
        } else if (digits[index] !== " ") {
          setDigit(index, "");
        }
      } else if (e.key === "ArrowLeft" && index > 0) {
        refs.current[index - 1]?.focus();
      } else if (e.key === "ArrowRight" && index < length - 1) {
        refs.current[index + 1]?.focus();
      }
    };

    const handlePaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
      const text = e.clipboardData.getData("text").replace(/\D/g, "");
      if (text.length === 0) return;
      e.preventDefault();
      onChange(text.slice(0, length));
      refs.current[Math.min(text.length, length - 1)]?.focus();
    };

    return (
      <div
        ref={ref}
        role="group"
        aria-label={ariaLabel}
        className={cn("flex items-center gap-2", invalid && "[&_input]:border-destructive")}
        data-testid="otp-input"
      >
        {Array.from({ length }).map((_, i) => {
          const ch = digits[i];
          return (
            <input
              key={i}
              ref={(el) => {
                refs.current[i] = el;
              }}
              type="text"
              inputMode="numeric"
              autoComplete={i === 0 ? "one-time-code" : "off"}
              maxLength={length}
              disabled={disabled}
              value={ch === " " ? "" : ch}
              onChange={handleChange(i)}
              onKeyDown={handleKeyDown(i)}
              onPaste={handlePaste}
              aria-label={`${ariaLabel} ${i + 1}`}
              aria-invalid={invalid ?? undefined}
              data-testid={`otp-cell-${i}`}
              className="size-12 rounded-xl border border-input bg-card text-center text-lg font-semibold shadow-xs focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2 disabled:opacity-50 md:size-14 md:text-xl"
            />
          );
        })}
        {name ? <input type="hidden" name={name} value={value} /> : null}
      </div>
    );
  },
);
OtpInput.displayName = "OtpInput";
