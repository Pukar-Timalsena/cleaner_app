const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a service title'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Please add a description']
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: ['house-cleaning', 'carpet-cleaning', 'window-cleaning', 'sanitary-cleaning', 'house-painting', 'other']
  },
  image: {
    type: String,
    default: null
  },
  basePrice: {
    type: Number,
    required: [true, 'Please add a base price']
  },
  location: {
    type: String,
    default: 'Kathmandu, Nepal'
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  reviewCount: {
    type: Number,
    default: 0
  },
  estimatedTime: {
    type: String,
    default: '2-3 hours'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Service', ServiceSchema);
