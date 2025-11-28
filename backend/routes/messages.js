const express = require('express');
const {
  sendMessage,
  getMessagesForBooking,
  getConversations,
  getAdminMessages,
  markAsRead,
  getDirectMessages
} = require('../controllers/messages');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect); // All routes require authentication

// Send a message
router.post('/', sendMessage);

// Get all conversations
router.get('/conversations', getConversations);

// Get messages with admin
router.get('/admin', getAdminMessages);

// Get messages for a specific booking
router.get('/booking/:bookingId', getMessagesForBooking);

// Get direct messages with a user
router.get('/direct/:userId', getDirectMessages);

// Mark messages as read
router.put('/:conversationId/read', markAsRead);

module.exports = router;
