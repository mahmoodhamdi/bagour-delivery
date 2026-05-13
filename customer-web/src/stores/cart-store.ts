import type { OrderItem } from "@bagour/types";
import { nanoid } from "@/lib/nanoid";
import { create } from "zustand";
import { createJSONStorage, persist, type PersistOptions } from "zustand/middleware";

export interface CartLine extends OrderItem {
  /** Stable id for this configured line so we can update / remove it. */
  lineId: string;
}

interface CartState {
  /** Restaurant the cart belongs to. The cart resets when adding from a different restaurant. */
  restaurantId: string | null;
  restaurantName: string | null;
  restaurantSlug: string | null;
  lines: CartLine[];
}

interface CartActions {
  addLine: (
    args: { restaurantId: string; restaurantName: string; restaurantSlug: string; line: OrderItem },
    options?: { confirmReplace?: () => boolean },
  ) => boolean;
  updateLineQuantity: (lineId: string, quantity: number) => void;
  removeLine: (lineId: string) => void;
  clear: () => void;
}

export type CartStore = CartState & CartActions;

const initialState: CartState = {
  restaurantId: null,
  restaurantName: null,
  restaurantSlug: null,
  lines: [],
};

const persistOptions: PersistOptions<CartStore, CartState> = {
  name: "bagour-cart",
  storage: createJSONStorage(() => localStorage),
  partialize: (state) => ({
    restaurantId: state.restaurantId,
    restaurantName: state.restaurantName,
    restaurantSlug: state.restaurantSlug,
    lines: state.lines,
  }),
};

export const useCartStore = create<CartStore>()(
  persist<CartStore, [], [], CartState>(
    (set, get) => ({
      ...initialState,
      addLine: ({ restaurantId, restaurantName, restaurantSlug, line }, options) => {
        const state = get();
        const switching = state.restaurantId && state.restaurantId !== restaurantId;
        if (switching) {
          const confirm = options?.confirmReplace ?? (() => true);
          if (!confirm()) return false;
          set({
            restaurantId,
            restaurantName,
            restaurantSlug,
            lines: [{ ...line, lineId: nanoid() }],
          });
          return true;
        }
        set({
          restaurantId,
          restaurantName,
          restaurantSlug,
          lines: [...state.lines, { ...line, lineId: nanoid() }],
        });
        return true;
      },
      updateLineQuantity: (lineId, quantity) =>
        set((s) => ({
          lines: s.lines
            .map((l) =>
              l.lineId === lineId
                ? { ...l, quantity, itemTotal: (l.itemTotal / l.quantity) * quantity }
                : l,
            )
            .filter((l) => l.quantity > 0),
        })),
      removeLine: (lineId) => set((s) => ({ lines: s.lines.filter((l) => l.lineId !== lineId) })),
      clear: () => set(initialState),
    }),
    persistOptions,
  ),
);

/** Selector helpers. */
export const selectCartCount = (s: CartStore) => s.lines.reduce((sum, l) => sum + l.quantity, 0);

export const selectCartSubtotal = (s: CartStore) =>
  s.lines.reduce((sum, l) => sum + l.itemTotal, 0);

export const selectIsCartEmpty = (s: CartStore) => s.lines.length === 0;
