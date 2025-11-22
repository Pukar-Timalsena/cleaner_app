const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  booking: {
    type: mongoose.Schema.ObjectId,
    ref: 'Booking',
    required: true
  },
  cleaner: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  location: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'ongoing', 'completed', 'cancelled'],
    default: 'pending'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  assignedAt: {
    type: Date,
    default: Date.now
  },
  startedAt: {
    type: Date,
    default: null
  },
  completedAt: {
    type: Date,
    default: null
  },
  duration: {
    type: Number, // in minutes
    default: null
  }
}, {
  timestamps: true
});

// Update task status timestamps
TaskSchema.pre('save', function(next) {
  if (this.isModified('status')) {
    if (this.status === 'ongoing' && !this.startedAt) {
      this.startedAt = new Date();
    }
    if (this.status === 'completed' && !this.completedAt) {
      this.completedAt = new Date();
      // Calculate duration if started
      if (this.startedAt) {
        this.duration = Math.round((this.completedAt - this.startedAt) / (1000 * 60));
      }
    }
  }
  next();
});

module.exports = mongoose.model('Task', TaskSchema);
