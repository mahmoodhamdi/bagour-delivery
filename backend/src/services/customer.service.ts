import { Types } from 'mongoose';
import Customer, { ICustomer, IAddress } from '@models/Customer';
import { BadRequestError, NotFoundError } from '@utils/errors';

interface AddAddressInput {
  label: 'home' | 'work' | 'other';
  name: string;
  address: string;
  area: string;
  city?: string;
  building?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  coordinates: [number, number]; // [lng, lat]
  isDefault?: boolean;
}

interface UpdateAddressInput extends Partial<AddAddressInput> {}

class CustomerService {
  /**
   * Get customer by user ID
   */
  async getByUserId(userId: string): Promise<ICustomer | null> {
    return Customer.findOne({ userId: new Types.ObjectId(userId) })
      .populate('userId', 'name email phone avatar');
  }

  /**
   * Get or create customer profile
   */
  async getOrCreateCustomer(userId: string): Promise<ICustomer> {
    let customer = await this.getByUserId(userId);

    if (!customer) {
      customer = await Customer.create({
        userId: new Types.ObjectId(userId),
        addresses: [],
        favorites: [],
        loyaltyPoints: 0,
        totalOrders: 0,
        totalSpent: 0,
      });
    }

    return customer;
  }

  /**
   * Get all addresses for a customer
   */
  async getAddresses(userId: string): Promise<IAddress[]> {
    const customer = await this.getOrCreateCustomer(userId);
    return customer.addresses;
  }

  /**
   * Get default address
   */
  async getDefaultAddress(userId: string): Promise<IAddress | null> {
    const customer = await this.getOrCreateCustomer(userId);
    return customer.addresses.find(addr => addr.isDefault) || customer.addresses[0] || null;
  }

  /**
   * Add a new address
   */
  async addAddress(userId: string, input: AddAddressInput): Promise<IAddress> {
    const customer = await this.getOrCreateCustomer(userId);

    // Check max addresses limit
    if (customer.addresses.length >= 10) {
      throw new BadRequestError('الحد الأقصى للعناوين هو 10');
    }

    // If this is the first address or marked as default, make it default
    const isDefault = customer.addresses.length === 0 || input.isDefault === true;

    // If setting as default, unset other defaults
    if (isDefault) {
      customer.addresses.forEach(addr => {
        addr.isDefault = false;
      });
    }

    const newAddress: any = {
      _id: new Types.ObjectId(),
      label: input.label,
      name: input.name,
      address: input.address,
      area: input.area,
      city: input.city || 'الباجور',
      building: input.building,
      floor: input.floor,
      apartment: input.apartment,
      landmark: input.landmark,
      location: {
        type: 'Point',
        coordinates: input.coordinates,
      },
      isDefault,
    };

    customer.addresses.push(newAddress);
    await customer.save();

    return newAddress;
  }

  /**
   * Update an address
   */
  async updateAddress(
    userId: string,
    addressId: string,
    input: UpdateAddressInput
  ): Promise<IAddress> {
    const customer = await this.getOrCreateCustomer(userId);

    const addressIndex = customer.addresses.findIndex(
      addr => addr._id.toString() === addressId
    );

    if (addressIndex === -1) {
      throw new NotFoundError('العنوان غير موجود');
    }

    const address = customer.addresses[addressIndex];

    // If setting as default, unset other defaults
    if (input.isDefault && !address.isDefault) {
      customer.addresses.forEach(addr => {
        addr.isDefault = false;
      });
    }

    // Update fields
    if (input.label) address.label = input.label;
    if (input.name) address.name = input.name;
    if (input.address) address.address = input.address;
    if (input.area) address.area = input.area;
    if (input.city) address.city = input.city;
    if (input.building !== undefined) address.building = input.building;
    if (input.floor !== undefined) address.floor = input.floor;
    if (input.apartment !== undefined) address.apartment = input.apartment;
    if (input.landmark !== undefined) address.landmark = input.landmark;
    if (input.coordinates) {
      address.location = {
        type: 'Point',
        coordinates: input.coordinates,
      };
    }
    if (input.isDefault !== undefined) address.isDefault = input.isDefault;

    await customer.save();
    return address;
  }

  /**
   * Delete an address
   */
  async deleteAddress(userId: string, addressId: string): Promise<void> {
    const customer = await this.getOrCreateCustomer(userId);

    const addressIndex = customer.addresses.findIndex(
      addr => addr._id.toString() === addressId
    );

    if (addressIndex === -1) {
      throw new NotFoundError('العنوان غير موجود');
    }

    const wasDefault = customer.addresses[addressIndex].isDefault;
    customer.addresses.splice(addressIndex, 1);

    // If we removed the default, set the first address as default
    if (wasDefault && customer.addresses.length > 0) {
      customer.addresses[0].isDefault = true;
    }

    await customer.save();
  }

  /**
   * Set default address
   */
  async setDefaultAddress(userId: string, addressId: string): Promise<IAddress> {
    const customer = await this.getOrCreateCustomer(userId);

    const addressIndex = customer.addresses.findIndex(
      addr => addr._id.toString() === addressId
    );

    if (addressIndex === -1) {
      throw new NotFoundError('العنوان غير موجود');
    }

    // Unset all defaults
    customer.addresses.forEach(addr => {
      addr.isDefault = false;
    });

    // Set new default
    customer.addresses[addressIndex].isDefault = true;

    await customer.save();
    return customer.addresses[addressIndex];
  }

  /**
   * Get customer favorites
   */
  async getFavorites(userId: string): Promise<Types.ObjectId[]> {
    const customer = await this.getOrCreateCustomer(userId);
    return customer.favorites;
  }

  /**
   * Add to favorites
   */
  async addToFavorites(userId: string, restaurantId: string): Promise<void> {
    const customer = await this.getOrCreateCustomer(userId);

    const restaurantObjId = new Types.ObjectId(restaurantId);

    if (!customer.favorites.some(id => id.equals(restaurantObjId))) {
      customer.favorites.push(restaurantObjId);
      await customer.save();
    }
  }

  /**
   * Remove from favorites
   */
  async removeFromFavorites(userId: string, restaurantId: string): Promise<void> {
    const customer = await this.getOrCreateCustomer(userId);

    customer.favorites = customer.favorites.filter(
      id => !id.equals(new Types.ObjectId(restaurantId))
    );

    await customer.save();
  }

  /**
   * Check if restaurant is in favorites
   */
  async isFavorite(userId: string, restaurantId: string): Promise<boolean> {
    const customer = await this.getOrCreateCustomer(userId);
    return customer.favorites.some(
      id => id.equals(new Types.ObjectId(restaurantId))
    );
  }

  /**
   * Update loyalty points
   */
  async updateLoyaltyPoints(userId: string, points: number): Promise<number> {
    const customer = await this.getOrCreateCustomer(userId);
    customer.loyaltyPoints = Math.max(0, customer.loyaltyPoints + points);
    await customer.save();
    return customer.loyaltyPoints;
  }

  /**
   * Get customer profile with stats
   */
  async getProfile(userId: string): Promise<ICustomer> {
    const customer = await this.getOrCreateCustomer(userId);
    await Customer.populate(customer, [
      { path: 'userId', select: 'name email phone avatar' },
      { path: 'favorites', select: 'name nameAr logo rating' },
    ]);
    return customer;
  }
}

export const customerService = new CustomerService();
export default customerService;
