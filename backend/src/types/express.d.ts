/* eslint-disable @typescript-eslint/no-unused-vars */

interface AuthUser {
  id: string;
  userId: string;
  role: string;
  email?: string;
}

declare namespace Express {
  interface Request {
    user?: AuthUser;
    customerId?: string;
    restaurantId?: string;
    driverId?: string;
  }
}

declare module 'express-serve-static-core' {
  interface Request {
    user?: AuthUser;
    customerId?: string;
    restaurantId?: string;
    driverId?: string;
  }
}

export {};
