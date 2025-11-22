const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema({
  booking: {
    type: mongoose.Schema.ObjectId,
    ref: 'Booking',
    required: true
  },
  customer: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  cleaner: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  service: {
    type: mongoose.Schema.ObjectId,
    ref: 'Service',
    required: true
  },
  rating: {
    type: Number,
    required: [true, 'Please add a rating'],
    min: 1,
    max: 5
  },
  comment: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Prevent duplicate reviews for same booking
ReviewSchema.index({ booking: 1 }, { unique: true });

// Update service and cleaner ratings after review
ReviewSchema.statics.updateRatings = async function(serviceId, cleanerId) {
  // Update service rating
  const serviceStats = await this.aggregate([
    { $match: { service: serviceId } },
    {
      $group: {
        _id: '$service',
        averageRating: { $avg: '$rating' },
        count: { $sum: 1 }
      }
    }
  ]);

  if (serviceStats.length > 0) {
    await mongoose.model('Service').findByIdAndUpdate(serviceId, {
      rating: serviceStats[0].averageRating.toFixed(1),
      reviewCount: serviceStats[0].count
    });
  }

  // Update cleaner rating
  const cleanerStats = await this.aggregate([
    { $match: { cleaner: cleanerId } },
    {
      $group: {
        _id: '$cleaner',
        averageRating: { $avg: '$rating' }
      }
    }
  ]);

  if (cleanerStats.length > 0) {
    await mongoose.model('User').findByIdAndUpdate(cleanerId, {
      rating: cleanerStats[0].averageRating.toFixed(1)
    });
  }
};

// Update ratings after save
ReviewSchema.post('save', async function() {
  await this.constructor.updateRatings(this.service, this.cleaner);
});

module.exports = mongoose.model('Review', ReviewSchema);
