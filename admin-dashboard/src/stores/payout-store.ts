import { create } from 'zustand';

export interface Payout {
  // Mongoose returns _id; the frontend templates use a flat `id`. Some
  // existing list views reference `payout.id` while detail views use _id —
  // keep both optional so the type compiles regardless of which the API
  // happens to serialise.
  _id?: string;
  id?: string;
  type?: 'restaurant' | 'driver';
  restaurantId?: { _id: string; name: string };
  driverId?: { _id: string; name: string };
  // Denormalised names the list view filters against without populating the
  // ref documents. Optional because legacy rows may only have the IDs.
  restaurantName?: string;
  driverName?: string;
  bankName?: string;
  amount: number;
  status: 'pending' | 'approved' | 'rejected' | 'paid' | 'completed';
  reference?: string;
  requestedAt?: string;
  processedAt?: string;
  rejectionReason?: string;
  createdAt: string;
  updatedAt?: string;
}

interface PayoutState {
  payouts: Payout[];
  isLoading: boolean;
  error: string | null;

  // The page component is responsible for the actual network calls (the
  // other stores in this dashboard follow the same pure-state pattern — see
  // dashboard.ts). The action stubs here keep the type contract callers
  // expect and let the component swap in real fetch logic.
  fetchPayouts: (status?: string) => Promise<void>;
  approvePayout: (id: string, reference?: string) => Promise<void>;
  rejectPayout: (id: string, reason: string) => Promise<void>;
  setPayouts: (payouts: Payout[]) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
}

export const usePayoutStore = create<PayoutState>((set) => ({
  payouts: [],
  isLoading: false,
  error: null,

  fetchPayouts: async () => {
    set({ isLoading: false, error: 'Connect to /admin/payouts via your API client' });
  },
  approvePayout: async () => {
    set({ error: 'Wire up POST /admin/payouts/:id/approve in your API client' });
  },
  rejectPayout: async () => {
    set({ error: 'Wire up POST /admin/payouts/:id/reject in your API client' });
  },
  setPayouts: (payouts) => set({ payouts }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
}));
