const Message = require('../models/Message');
const User = require('../models/User');
const Booking = require('../models/Booking');

// @desc    Send a message
// @route   POST /api/messages
// @access  Private
exports.sendMessage = async (req, res, next) => {
  try {
    const { recipientId, recipientType, message, bookingId } = req.body;

    // Validate recipient exists
    let recipient;
    if (recipientType === 'admin') {
      // Find any admin user
      recipient = await User.findOne({ role: 'admin' });
      if (!recipient) {
        return res.status(404).json({ success: false, error: 'Admin not found' });
      }
    } else {
      recipient = await User.findById(recipientId);
      if (!recipient) {
        return res.status(404).json({ success: false, error: 'Recipient not found' });
      }
    }

    // Create message
    const messageData = {
      sender: req.user.id,
      recipient: recipient._id,
      message: message
    };

    // Add booking reference if provided
    if (bookingId) {
      const booking = await Booking.findOne({ bookingId: bookingId });
      if (booking) {
        messageData.booking = booking._id;
      }
    }

    const newMessage = await Message.create(messageData);

    // Populate sender info for response
    const populatedMessage = await Message.findById(newMessage._id)
      .populate('sender', 'name email role')
      .populate('recipient', 'name email role');

    res.status(201).json({
      success: true,
      data: populatedMessage
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get messages for a specific booking
// @route   GET /api/messages/booking/:bookingId
// @access  Private
exports.getMessagesForBooking = async (req, res, next) => {
  try {
    const { bookingId } = req.params;

    // Find booking by bookingId string (e.g., "BK001")
    const booking = await Booking.findOne({ bookingId: bookingId });

    if (!booking) {
      // Return empty array if booking not found (not an error)
      return res.status(200).json({
        success: true,
        count: 0,
        data: []
      });
    }

    // Check if user is authorized to view messages for this booking
    const isCustomer = booking.customer.toString() === req.user.id;
    const isCleaner = booking.cleaner && booking.cleaner.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';

    if (!isCustomer && !isCleaner && !isAdmin) {
      return res.status(403).json({ success: false, error: 'Not authorized to view these messages' });
    }

    // Get all messages for this booking
    const messages = await Message.find({ booking: booking._id })
      .populate('sender', 'name email role')
      .populate('recipient', 'name email role')
      .sort('createdAt');

    // Add isFromCurrentUser flag
    const messagesWithFlag = messages.map(msg => ({
      ...msg.toObject(),
      isFromCurrentUser: msg.sender._id.toString() === req.user.id
    }));

    res.status(200).json({
      success: true,
      count: messagesWithFlag.length,
      data: messagesWithFlag
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all conversations for current user
// @route   GET /api/messages/conversations
// @access  Private
exports.getConversations = async (req, res, next) => {
  try {
    // Find all unique conversations
    const sentMessages = await Message.aggregate([
      { $match: { sender: req.user._id } },
      { $group: { _id: '$recipient', lastMessage: { $last: '$$ROOT' } } }
    ]);

    const receivedMessages = await Message.aggregate([
      { $match: { recipient: req.user._id } },
      { $group: { _id: '$sender', lastMessage: { $last: '$$ROOT' } } }
    ]);

    // Combine and deduplicate
    const conversationMap = new Map();

    for (const conv of [...sentMessages, ...receivedMessages]) {
      const partnerId = conv._id.toString();
      if (!conversationMap.has(partnerId) ||
          new Date(conv.lastMessage.createdAt) > new Date(conversationMap.get(partnerId).lastMessage.createdAt)) {
        conversationMap.set(partnerId, conv);
      }
    }

    // Get user details for each conversation
    const conversations = await Promise.all(
      Array.from(conversationMap.values()).map(async (conv) => {
        const partner = await User.findById(conv._id).select('name email role');
        const unreadCount = await Message.countDocuments({
          sender: conv._id,
          recipient: req.user._id,
          isRead: false
        });
        return {
          partner,
          lastMessage: conv.lastMessage,
          unreadCount
        };
      })
    );

    // Sort by last message time
    conversations.sort((a, b) =>
      new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt)
    );

    res.status(200).json({
      success: true,
      count: conversations.length,
      data: conversations
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get messages with admin
// @route   GET /api/messages/admin
// @access  Private
exports.getAdminMessages = async (req, res, next) => {
  try {
    // Find admin user
    const admin = await User.findOne({ role: 'admin' });

    if (!admin) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: []
      });
    }

    // Get messages between current user and admin
    const messages = await Message.find({
      $or: [
        { sender: req.user.id, recipient: admin._id },
        { sender: admin._id, recipient: req.user.id }
      ]
    })
      .populate('sender', 'name email role')
      .populate('recipient', 'name email role')
      .sort('createdAt');

    // Add isFromCurrentUser flag
    const messagesWithFlag = messages.map(msg => ({
      ...msg.toObject(),
      isFromCurrentUser: msg.sender._id.toString() === req.user.id
    }));

    res.status(200).json({
      success: true,
      count: messagesWithFlag.length,
      data: messagesWithFlag
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Mark messages as read
// @route   PUT /api/messages/:conversationId/read
// @access  Private
exports.markAsRead = async (req, res, next) => {
  try {
    const { conversationId } = req.params;

    // Mark all messages from this sender as read
    await Message.updateMany(
      {
        sender: conversationId,
        recipient: req.user.id,
        isRead: false
      },
      {
        isRead: true,
        readAt: new Date()
      }
    );

    res.status(200).json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get direct messages between two users
// @route   GET /api/messages/direct/:userId
// @access  Private
exports.getDirectMessages = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const messages = await Message.find({
      $or: [
        { sender: req.user.id, recipient: userId },
        { sender: userId, recipient: req.user.id }
      ]
    })
      .populate('sender', 'name email role')
      .populate('recipient', 'name email role')
      .sort('createdAt');

    // Add isFromCurrentUser flag
    const messagesWithFlag = messages.map(msg => ({
      ...msg.toObject(),
      isFromCurrentUser: msg.sender._id.toString() === req.user.id
    }));

    res.status(200).json({
      success: true,
      count: messagesWithFlag.length,
      data: messagesWithFlag
    });
  } catch (err) {
    next(err);
  }
};
