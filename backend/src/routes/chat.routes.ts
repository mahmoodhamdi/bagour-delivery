import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import {
  getOrCreateChat,
  sendMessage,
  getMessages,
  markAsRead,
  getUserChats,
  getChatByOrder,
  getUnreadCount,
} from '../controllers/chat.controller';
import {
  getOrCreateChatSchema,
  sendMessageSchema,
  getMessagesSchema,
  chatIdSchema,
  orderChatSchema,
  chatsListSchema,
} from '../validators/chat.validators';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/chats
 * @desc    Get user's chat list
 * @access  Private (customer, restaurant, driver)
 */
router.get(
  '/',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  validate(chatsListSchema),
  getUserChats
);

/**
 * @route   GET /api/v1/chats/unread-count
 * @desc    Get unread messages count
 * @access  Private (customer, restaurant, driver)
 */
router.get(
  '/unread-count',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  getUnreadCount
);

/**
 * @route   GET /api/v1/chats/order/:orderId
 * @desc    Get or create chat for an order
 * @access  Private (customer, restaurant, driver)
 */
router.get(
  '/order/:orderId',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  validate(getOrCreateChatSchema),
  getOrCreateChat
);

/**
 * @route   GET /api/v1/chats/:chatId/messages
 * @desc    Get chat messages
 * @access  Private (customer, restaurant, driver)
 */
router.get(
  '/:chatId/messages',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  validate(getMessagesSchema),
  getMessages
);

/**
 * @route   POST /api/v1/chats/:chatId/messages
 * @desc    Send a message in a chat
 * @access  Private (customer, restaurant, driver)
 */
router.post(
  '/:chatId/messages',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  validate(sendMessageSchema),
  sendMessage
);

/**
 * @route   PUT /api/v1/chats/:chatId/read
 * @desc    Mark chat messages as read
 * @access  Private (customer, restaurant, driver)
 */
router.put(
  '/:chatId/read',
  authorize('customer', 'restaurant', 'driver', 'delivery'),
  validate(chatIdSchema),
  markAsRead
);

export default router;
