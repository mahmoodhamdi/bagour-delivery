declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        userId: string;
        role: string;
        email?: string;
      };
    }
  }
}

export {};
