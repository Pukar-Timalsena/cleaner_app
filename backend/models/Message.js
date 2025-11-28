const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  recipient: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  booking: {
    type: mongoose.Schema.ObjectId,
    ref: 'Booking',
    default: null
  },
  message: {
    type: String,
    required: [true, 'Please add a message'],
    trim: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

// Index for faster queries
MessageSchema.index({ sender: 1, recipient: 1, createdAt: -1 });
MessageSchema.index({ booking: 1, createdAt: -1 });

module.exports = mongoose.model('Message', MessageSchema);
