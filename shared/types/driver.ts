export type DriverStatus = 'pending' | 'approved' | 'rejected' | 'suspended';
export type VehicleType = 'motorcycle' | 'bicycle' | 'car';

export interface DriverDocuments {
  nationalIdFront?: string;
  nationalIdBack?: string;
  driverLicenseFront?: string;
  driverLicenseBack?: string;
  vehicleLicense?: string;
  vehicleImage?: string;
}

export interface Driver {
  id: string;
  userId: string;
  nationalId: string;
  dateOfBirth: Date;
  vehicleType: VehicleType;
  vehicleModel?: string;
  vehicleColor?: string;
  vehiclePlateNumber: string;
  licenseNumber: string;
  licenseExpiryDate: Date;
  documents: DriverDocuments;
  status: DriverStatus;
  rejectionReason?: string;
  isOnline: boolean;
  isAvailable: boolean;
  currentLocation?: {
    type: 'Point';
    coordinates: [number, number]; // [lng, lat]
    updatedAt: Date;
  };
  currentOrderId?: string;
  rating: number;
  totalReviews: number;
  totalDeliveries: number;
  totalEarnings: number;
  walletBalance: number;
  bankDetails?: {
    bankName: string;
    accountNumber: string;
    accountHolderName: string;
  };
  zones: string[]; // Zone IDs the driver operates in
  createdAt: Date;
  updatedAt: Date;
}
