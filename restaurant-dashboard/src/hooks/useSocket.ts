'use client';

import { useEffect, useRef } from 'react';
import { initSocket, disconnectSocket } from '@/lib/socket';
import { useAuthStore } from '@/stores/auth';

export function useSocket() {
  const { restaurant, isAuthenticated } = useAuthStore();
  const initialized = useRef(false);

  useEffect(() => {
    if (isAuthenticated && restaurant?.id && !initialized.current) {
      initialized.current = true;
      initSocket(restaurant.id);
    }

    return () => {
      if (initialized.current) {
        disconnectSocket();
        initialized.current = false;
      }
    };
  }, [isAuthenticated, restaurant?.id]);
}
