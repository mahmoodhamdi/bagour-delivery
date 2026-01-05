import mongoose from 'mongoose';
import { Chat, IChat, IChatMessage } from '../models/Chat';
import { Order } from '../models/Order';
import { Customer } from '../models/Customer';
import { Restaurant } from '../models/Restaurant';
import { Driver } from '../models/Driver';
import { NotFoundError, BadRequestError, ForbiddenError } from '../utils/errors';
import { emitToUser, emitToRestaurant, emitToDriver, emitToOrder } from '../config/socket';

class ChatService {
  /**
   * Get or create a chat for an order
   */
  async getOrCreateChat(
    orderId: string,
    chatType: 'customer_restaurant' | 'customer_driver' | 'restaurant_driver',
    userId: string,
    userRole: string
  ): Promise<IChat> {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new NotFoundError('الطلب غير موجود');
    }

    // Verify user is a participant
    const isParticipant = await this.verifyParticipant(order, userId, userRole, chatType);
    if (!isParticipant) {
      throw new ForbiddenError('غير مصرح لك بالوصول لهذه المحادثة');
    }

    // Get participant IDs
    const participants = {
      customerId: order.customerId,
      restaurantId: undefined as mongoose.Types.ObjectId | undefined,
      driverId: undefined as mongoose.Types.ObjectId | undefined,
    };

    if (chatType === 'customer_restaurant' || chatType === 'restaurant_driver') {
      const restaurant = await Restaurant.findById(order.restaurantId);
      if (restaurant) {
        participants.restaurantId = restaurant._id as mongoose.Types.ObjectId;
      }
    }

    if (chatType === 'customer_driver' || chatType === 'restaurant_driver') {
      if (order.driverId) {
        const driver = await Driver.findOne({ userId: order.driverId });
        if (driver) {
          participants.driverId = driver._id as mongoose.Types.ObjectId;
        }
      }
    }

    // Find or create the chat
    let chat = await Chat.findOne({ orderId, chatType });

    if (!chat) {
      chat = await Chat.create({
        orderId,
        chatType,
        participants,
        messages: [],
        isActive: true,
      });
    }

    return chat;
  }

  /**
   * Send a message in a chat
   */
  async sendMessage(
    chatId: string,
    userId: string,
    userRole: string,
    content: string,
    type: 'text' | 'image' | 'location' = 'text',
    extras?: { imageUrl?: string; location?: { lat: number; lng: number } }
  ): Promise<IChatMessage> {
    const chat = await Chat.findById(chatId);
    if (!chat) {
      throw new NotFoundError('المحادثة غير موجودة');
    }

    if (!chat.isActive) {
      throw new BadRequestError('المحادثة مغلقة');
    }

    // Determine sender role for chat
    let senderRole: 'customer' | 'restaurant' | 'driver';
    if (userRole === 'customer') {
      senderRole = 'customer';
    } else if (userRole === 'restaurant') {
      senderRole = 'restaurant';
    } else if (userRole === 'driver' || userRole === 'delivery') {
      senderRole = 'driver';
    } else {
      throw new ForbiddenError('غير مصرح لك بإرسال رسائل');
    }

    // Add message
    const message: IChatMessage = {
      sender: new mongoose.Types.ObjectId(userId),
      senderRole,
      content,
      type,
      imageUrl: extras?.imageUrl,
      location: extras?.location,
      isRead: false,
      createdAt: new Date(),
    };

    chat.messages.push(message);
    chat.lastMessage = type === 'text' ? content : type === 'image' ? '📷 صورة' : '📍 موقع';
    chat.lastMessageAt = new Date();
    chat.lastMessageBy = new mongoose.Types.ObjectId(userId);

    await chat.save();

    const newMessage = chat.messages[chat.messages.length - 1];

    // Emit socket event for real-time updates
    const messageData = {
      chatId: chat._id,
      orderId: chat.orderId,
      message: newMessage,
    };

    // Notify participants
    if (chat.participants.customerId && senderRole !== 'customer') {
      const customer = await Customer.findById(chat.participants.customerId);
      if (customer) {
        emitToUser(customer.userId.toString(), 'chat:message', messageData);
      }
    }

    if (chat.participants.restaurantId && senderRole !== 'restaurant') {
      emitToRestaurant(chat.participants.restaurantId.toString(), 'chat:message', messageData);
    }

    if (chat.participants.driverId && senderRole !== 'driver') {
      const driver = await Driver.findById(chat.participants.driverId);
      if (driver) {
        emitToDriver(driver.userId.toString(), 'chat:message', messageData);
      }
    }

    // Also emit to order room
    emitToOrder(chat.orderId.toString(), 'chat:message', messageData);

    return newMessage;
  }

  /**
   * Get chat messages with pagination
   */
  async getMessages(
    chatId: string,
    userId: string,
    userRole: string,
    page: number = 1,
    limit: number = 50
  ): Promise<{
    messages: IChatMessage[];
    total: number;
    page: number;
    pages: number;
  }> {
    const chat = await Chat.findById(chatId);
    if (!chat) {
      throw new NotFoundError('المحادثة غير موجودة');
    }

    // Mark messages as read
    await chat.markAsRead(new mongoose.Types.ObjectId(userId));

    // Get paginated messages (most recent first)
    const total = chat.messages.length;
    const pages = Math.ceil(total / limit);
    const startIndex = Math.max(0, total - page * limit);
    const endIndex = total - (page - 1) * limit;

    const messages = chat.messages
      .slice(startIndex, endIndex)
      .reverse(); // Return in chronological order

    return {
      messages,
      total,
      page,
      pages,
    };
  }

  /**
   * Mark chat messages as read
   */
  async markAsRead(chatId: string, userId: string): Promise<boolean> {
    const chat = await Chat.findById(chatId);
    if (!chat) {
      throw new NotFoundError('المحادثة غير موجودة');
    }

    const updated = await chat.markAsRead(new mongoose.Types.ObjectId(userId));

    if (updated) {
      // Emit read receipt
      emitToOrder(chat.orderId.toString(), 'chat:read', {
        chatId: chat._id,
        readBy: userId,
        readAt: new Date(),
      });
    }

    return updated;
  }

  /**
   * Get user's chat list
   */
  async getUserChats(
    userId: string,
    userRole: string,
    page: number = 1,
    limit: number = 20
  ): Promise<{
    chats: IChat[];
    total: number;
    page: number;
    pages: number;
  }> {
    let query: Record<string, unknown> = {};

    if (userRole === 'customer') {
      const customer = await Customer.findOne({ userId });
      if (!customer) {
        throw new NotFoundError('العميل غير موجود');
      }
      query = { 'participants.customerId': customer._id };
    } else if (userRole === 'restaurant') {
      const restaurant = await Restaurant.findOne({ userId });
      if (!restaurant) {
        throw new NotFoundError('المطعم غير موجود');
      }
      query = { 'participants.restaurantId': restaurant._id };
    } else if (userRole === 'driver' || userRole === 'delivery') {
      const driver = await Driver.findOne({ userId });
      if (!driver) {
        throw new NotFoundError('السائق غير موجود');
      }
      query = { 'participants.driverId': driver._id };
    }

    const total = await Chat.countDocuments(query);
    const pages = Math.ceil(total / limit);
    const skip = (page - 1) * limit;

    const chats = await Chat.find(query)
      .populate('orderId', 'orderNumber status')
      .sort({ lastMessageAt: -1 })
      .skip(skip)
      .limit(limit);

    return {
      chats,
      total,
      page,
      pages,
    };
  }

  /**
   * Get chat by order ID
   */
  async getChatByOrder(
    orderId: string,
    chatType: 'customer_restaurant' | 'customer_driver' | 'restaurant_driver',
    userId: string,
    userRole: string
  ): Promise<IChat | null> {
    const chat = await Chat.findOne({ orderId, chatType });

    if (chat) {
      // Mark as read when accessed
      await chat.markAsRead(new mongoose.Types.ObjectId(userId));
    }

    return chat;
  }

  /**
   * Deactivate chat (usually when order is completed/cancelled)
   */
  async deactivateChat(orderId: string): Promise<void> {
    await Chat.updateMany(
      { orderId },
      { isActive: false }
    );
  }

  /**
   * Get unread count for user
   */
  async getUnreadCount(userId: string, userRole: string): Promise<number> {
    let query: Record<string, unknown> = {};

    if (userRole === 'customer') {
      const customer = await Customer.findOne({ userId });
      if (!customer) return 0;
      query = { 'participants.customerId': customer._id };
    } else if (userRole === 'restaurant') {
      const restaurant = await Restaurant.findOne({ userId });
      if (!restaurant) return 0;
      query = { 'participants.restaurantId': restaurant._id };
    } else if (userRole === 'driver' || userRole === 'delivery') {
      const driver = await Driver.findOne({ userId });
      if (!driver) return 0;
      query = { 'participants.driverId': driver._id };
    }

    const chats = await Chat.find({ ...query, isActive: true });

    let totalUnread = 0;
    for (const chat of chats) {
      totalUnread += chat.getUnreadCount(new mongoose.Types.ObjectId(userId));
    }

    return totalUnread;
  }

  /**
   * Verify user is a participant in the chat type
   */
  private async verifyParticipant(
    order: typeof Order.prototype,
    userId: string,
    userRole: string,
    chatType: 'customer_restaurant' | 'customer_driver' | 'restaurant_driver'
  ): Promise<boolean> {
    if (userRole === 'customer') {
      const customer = await Customer.findOne({ userId });
      if (!customer) return false;
      return customer._id.toString() === order.customerId.toString() &&
        (chatType === 'customer_restaurant' || chatType === 'customer_driver');
    }

    if (userRole === 'restaurant') {
      const restaurant = await Restaurant.findOne({ userId });
      if (!restaurant) return false;
      return restaurant._id.toString() === order.restaurantId.toString() &&
        (chatType === 'customer_restaurant' || chatType === 'restaurant_driver');
    }

    if (userRole === 'driver' || userRole === 'delivery') {
      const driver = await Driver.findOne({ userId });
      if (!driver || !order.driverId) return false;
      return driver.userId.toString() === order.driverId.toString() &&
        (chatType === 'customer_driver' || chatType === 'restaurant_driver');
    }

    return false;
  }
}

export const chatService = new ChatService();
export default chatService;
