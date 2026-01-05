import mongoose, { Schema, Document } from 'mongoose';

export interface IChatMessage {
  _id?: mongoose.Types.ObjectId;
  sender: mongoose.Types.ObjectId;
  senderRole: 'customer' | 'restaurant' | 'driver';
  content: string;
  type: 'text' | 'image' | 'location';
  imageUrl?: string;
  location?: {
    lat: number;
    lng: number;
  };
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
}

export interface IChat extends Document {
  orderId: mongoose.Types.ObjectId;
  participants: {
    customerId: mongoose.Types.ObjectId;
    restaurantId?: mongoose.Types.ObjectId;
    driverId?: mongoose.Types.ObjectId;
  };
  chatType: 'customer_restaurant' | 'customer_driver' | 'restaurant_driver';
  messages: IChatMessage[];
  lastMessage?: string;
  lastMessageAt?: Date;
  lastMessageBy?: mongoose.Types.ObjectId;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;

  // Methods
  addMessage(
    senderId: mongoose.Types.ObjectId,
    senderRole: 'customer' | 'restaurant' | 'driver',
    content: string,
    type?: 'text' | 'image' | 'location',
    extras?: { imageUrl?: string; location?: { lat: number; lng: number } }
  ): Promise<IChatMessage>;
  markAsRead(readerId: mongoose.Types.ObjectId): Promise<boolean>;
  getUnreadCount(userId: mongoose.Types.ObjectId): number;
}

const chatMessageSchema = new Schema<IChatMessage>(
  {
    sender: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    senderRole: {
      type: String,
      enum: ['customer', 'restaurant', 'driver'],
      required: true,
    },
    content: {
      type: String,
      required: true,
      maxlength: [1000, 'الرسالة طويلة جداً'],
    },
    type: {
      type: String,
      enum: ['text', 'image', 'location'],
      default: 'text',
    },
    imageUrl: {
      type: String,
    },
    location: {
      lat: Number,
      lng: Number,
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: {
      type: Date,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: true }
);

const chatSchema = new Schema<IChat>(
  {
    orderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
      required: true,
      index: true,
    },
    participants: {
      customerId: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
      },
      restaurantId: {
        type: Schema.Types.ObjectId,
        ref: 'Restaurant',
      },
      driverId: {
        type: Schema.Types.ObjectId,
        ref: 'Driver',
      },
    },
    chatType: {
      type: String,
      enum: ['customer_restaurant', 'customer_driver', 'restaurant_driver'],
      required: true,
    },
    messages: [chatMessageSchema],
    lastMessage: {
      type: String,
    },
    lastMessageAt: {
      type: Date,
    },
    lastMessageBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for finding chats by participants
chatSchema.index({ 'participants.customerId': 1, 'participants.restaurantId': 1 });
chatSchema.index({ 'participants.customerId': 1, 'participants.driverId': 1 });
chatSchema.index({ 'participants.restaurantId': 1, 'participants.driverId': 1 });

// Index for listing user's chats sorted by last message
chatSchema.index({ 'participants.customerId': 1, lastMessageAt: -1 });
chatSchema.index({ 'participants.driverId': 1, lastMessageAt: -1 });

// Virtual to populate order
chatSchema.virtual('order', {
  ref: 'Order',
  localField: 'orderId',
  foreignField: '_id',
  justOne: true,
});

// Static method to find or create chat for an order
chatSchema.statics.findOrCreateForOrder = async function (
  orderId: mongoose.Types.ObjectId,
  chatType: 'customer_restaurant' | 'customer_driver' | 'restaurant_driver',
  participants: {
    customerId: mongoose.Types.ObjectId;
    restaurantId?: mongoose.Types.ObjectId;
    driverId?: mongoose.Types.ObjectId;
  }
) {
  let chat = await this.findOne({ orderId, chatType });

  if (!chat) {
    chat = await this.create({
      orderId,
      chatType,
      participants,
      messages: [],
      isActive: true,
    });
  }

  return chat;
};

// Method to add a message
chatSchema.methods.addMessage = async function (
  senderId: mongoose.Types.ObjectId,
  senderRole: 'customer' | 'restaurant' | 'driver',
  content: string,
  type: 'text' | 'image' | 'location' = 'text',
  extras?: { imageUrl?: string; location?: { lat: number; lng: number } }
) {
  const message: IChatMessage = {
    sender: senderId,
    senderRole,
    content,
    type,
    imageUrl: extras?.imageUrl,
    location: extras?.location,
    isRead: false,
    createdAt: new Date(),
  };

  this.messages.push(message);
  this.lastMessage = content;
  this.lastMessageAt = new Date();
  this.lastMessageBy = senderId;

  await this.save();

  return this.messages[this.messages.length - 1];
};

// Method to mark messages as read
chatSchema.methods.markAsRead = async function (
  readerId: mongoose.Types.ObjectId
) {
  let updated = false;

  this.messages.forEach((message: IChatMessage) => {
    if (!message.isRead && message.sender.toString() !== readerId.toString()) {
      message.isRead = true;
      message.readAt = new Date();
      updated = true;
    }
  });

  if (updated) {
    await this.save();
  }

  return updated;
};

// Method to get unread count for a user
chatSchema.methods.getUnreadCount = function (
  userId: mongoose.Types.ObjectId
): number {
  return this.messages.filter(
    (m: IChatMessage) => !m.isRead && m.sender.toString() !== userId.toString()
  ).length;
};

export const Chat = mongoose.model<IChat>('Chat', chatSchema);

export default Chat;
