import { Request, Response, NextFunction } from 'express';
import { chatService } from '../services/chat.service';
import { sendSuccess, sendCreated, sendPaginated } from '../utils/response';

/**
 * Get or create chat for an order
 */
export const getOrCreateChat = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { orderId } = req.params;
    const { chatType } = req.query;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const chat = await chatService.getOrCreateChat(
      orderId,
      chatType as 'customer_restaurant' | 'customer_driver' | 'restaurant_driver',
      userId,
      userRole
    );

    sendSuccess(res, chat, 'تم جلب المحادثة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Send a message in a chat
 */
export const sendMessage = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { chatId } = req.params;
    const { content, type, imageUrl, location } = req.body;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const message = await chatService.sendMessage(
      chatId,
      userId,
      userRole,
      content,
      type || 'text',
      { imageUrl, location }
    );

    sendCreated(res, message, 'تم إرسال الرسالة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get chat messages
 */
export const getMessages = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { chatId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const result = await chatService.getMessages(
      chatId,
      userId,
      userRole,
      Number(page),
      Number(limit)
    );

    sendPaginated(res, result.messages, {
      total: result.total,
      page: result.page,
      limit: Number(limit),
      pages: result.pages,
    }, 'تم جلب الرسائل بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Mark chat as read
 */
export const markAsRead = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { chatId } = req.params;
    const userId = req.user!.id;

    await chatService.markAsRead(chatId, userId);

    sendSuccess(res, null, 'تم تحديث حالة القراءة');
  } catch (error) {
    next(error);
  }
};

/**
 * Get user's chats list
 */
export const getUserChats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const result = await chatService.getUserChats(
      userId,
      userRole,
      Number(page),
      Number(limit)
    );

    sendPaginated(res, result.chats, {
      total: result.total,
      page: result.page,
      limit: Number(limit),
      pages: result.pages,
    }, 'تم جلب المحادثات بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get chat by order
 */
export const getChatByOrder = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { orderId } = req.params;
    const { chatType } = req.query;
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const chat = await chatService.getChatByOrder(
      orderId,
      chatType as 'customer_restaurant' | 'customer_driver' | 'restaurant_driver',
      userId,
      userRole
    );

    sendSuccess(res, chat, 'تم جلب المحادثة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get unread count
 */
export const getUnreadCount = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;

    const count = await chatService.getUnreadCount(userId, userRole);

    sendSuccess(res, { count }, 'تم جلب عدد الرسائل غير المقروءة');
  } catch (error) {
    next(error);
  }
};

export default {
  getOrCreateChat,
  sendMessage,
  getMessages,
  markAsRead,
  getUserChats,
  getChatByOrder,
  getUnreadCount,
};
