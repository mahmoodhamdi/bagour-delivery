"use client";

import { useEffect } from "react";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("[global-error]", error);
  }, [error]);

  return (
    <html lang="en">
      <body
        style={{
          fontFamily: "system-ui, -apple-system, sans-serif",
          padding: "2rem",
          textAlign: "center",
          background: "#fdfaf6",
          color: "#1a1612",
        }}
      >
        <h1 style={{ fontSize: "1.5rem", marginBottom: "0.5rem" }}>Something went wrong</h1>
        <p style={{ color: "#666", marginBottom: "1.5rem" }}>
          {error.digest ? `Reference: ${error.digest}` : "An unexpected error occurred."}
        </p>
        <button
          type="button"
          onClick={reset}
          style={{
            background: "#cf6f2c",
            color: "#fff",
            border: 0,
            padding: "0.75rem 1.5rem",
            borderRadius: "0.75rem",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          Try again
        </button>
      </body>
    </html>
  );
}
