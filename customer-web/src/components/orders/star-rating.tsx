"use client";

import { Star } from "lucide-react";
import * as React from "react";

import { cn } from "@/lib/utils";

interface StarRatingProps {
  value: number;
  onChange?: (value: number) => void;
  max?: number;
  ariaLabel: string;
  /** Visual size of each star. */
  size?: "md" | "lg";
  /** Read-only display. */
  readOnly?: boolean;
}

/**
 * Accessible 1-5 star rating. Renders as radio buttons under the hood
 * so a screen reader announces "X of Y".
 */
export function StarRating({
  value,
  onChange,
  max = 5,
  ariaLabel,
  size = "md",
  readOnly,
}: StarRatingProps) {
  const stars = Array.from({ length: max }, (_, i) => i + 1);

  return (
    <div
      role={readOnly ? "img" : "radiogroup"}
      aria-label={ariaLabel}
      aria-readonly={readOnly ? true : undefined}
      className="inline-flex items-center gap-1"
    >
      {stars.map((n) => {
        const filled = n <= value;
        const sizeClass = size === "lg" ? "size-8" : "size-6";
        if (readOnly) {
          return (
            <Star
              key={n}
              aria-hidden
              className={cn(
                sizeClass,
                filled ? "fill-amber-400 text-amber-500" : "fill-transparent text-muted-foreground",
              )}
            />
          );
        }
        return (
          <button
            key={n}
            type="button"
            role="radio"
            aria-checked={value === n}
            aria-label={`${n} / ${max}`}
            tabIndex={value === n || (!value && n === 1) ? 0 : -1}
            onClick={() => onChange?.(n)}
            onKeyDown={(e) => {
              if (e.key === "ArrowRight" || e.key === "ArrowUp") {
                e.preventDefault();
                onChange?.(Math.min(max, value + 1 || 1));
              } else if (e.key === "ArrowLeft" || e.key === "ArrowDown") {
                e.preventDefault();
                onChange?.(Math.max(1, value - 1));
              }
            }}
            className="rounded-md p-0.5 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
          >
            <Star
              aria-hidden
              className={cn(
                sizeClass,
                "transition-colors",
                filled ? "fill-amber-400 text-amber-500" : "fill-transparent text-muted-foreground",
              )}
            />
          </button>
        );
      })}
    </div>
  );
}
