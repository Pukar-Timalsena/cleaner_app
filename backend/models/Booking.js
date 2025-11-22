const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
  bookingId: {
    type: String,
    unique: true,
    required: true
  },
  customer: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  service: {
    type: mongoose.Schema.ObjectId,
    ref: 'Service',
    required: true
  },
  cleaner: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    default: null
  },
  customerName: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    required: true
  },
  address: {
    type: String,
    required: true
  },
  bookingDate: {
    type: Date,
    required: [true, 'Please add a booking date']
  },
  bookingTime: {
    type: String,
    required: [true, 'Please add a booking time']
  },
  location: {
    type: String,
    required: true
  },
  duration: {
    type: String,
    default: '2-3 hours'
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'digital_wallet'],
    required: true
  },
  subtotal: {
    type: Number,
    required: true
  },
  discount: {
    type: Number,
    default: 0
  },
  total: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'assigned', 'in_progress', 'completed', 'cancelled'],
    default: 'pending'
  },
  notes: {
    type: String,
    default: ''
  },
  completedAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

// Generate unique booking ID before saving
BookingSchema.pre('save', async function(next) {
  if (!this.isNew) {
    return next();
  }

  // Generate booking ID like BK001, BK002, etc.
  const count = await mongoose.model('Booking').countDocuments();
  this.bookingId = `BK${String(count + 1).padStart(3, '0')}`;
  next();
});

module.exports = mongoose.model('Booking', BookingSchema);
