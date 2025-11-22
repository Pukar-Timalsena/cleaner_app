const Review = require('../models/Review');
const Booking = require('../models/Booking');

// @desc    Create new review
// @route   POST /api/reviews
// @access  Private
exports.createReview = async (req, res, next) => {
  try {
    const { bookingId, rating, comment } = req.body;

    // Get booking
    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found' });
    }

    // Check if booking is completed
    if (booking.status !== 'completed') {
      return res.status(400).json({ success: false, error: 'Can only review completed bookings' });
    }

    // Check if user is the customer
    if (booking.customer.toString() !== req.user.id) {
      return res.status(403).json({ success: false, error: 'Not authorized to review this booking' });
    }

    // Check if review already exists
    const existingReview = await Review.findOne({ booking: bookingId });
    if (existingReview) {
      return res.status(400).json({ success: false, error: 'Review already exists for this booking' });
    }

    // Create review
    const review = await Review.create({
      booking: bookingId,
      customer: req.user.id,
      cleaner: booking.cleaner,
      service: booking.service,
      rating,
      comment
    });

    const populatedReview = await Review.findById(review._id)
      .populate('customer', 'name profileImage')
      .populate('service', 'title')
      .populate('cleaner', 'name');

    res.status(201).json({
      success: true,
      data: populatedReview
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get review
// @route   GET /api/reviews/:id
// @access  Private
exports.getReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id)
      .populate('customer', 'name profileImage')
      .populate('service', 'title')
      .populate('cleaner', 'name rating')
      .populate('booking', 'bookingId');

    if (!review) {
      return res.status(404).json({ success: false, error: 'Review not found' });
    }

    res.status(200).json({
      success: true,
      data: review
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update review
// @route   PUT /api/reviews/:id
// @access  Private
exports.updateReview = async (req, res, next) => {
  try {
    let review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({ success: false, error: 'Review not found' });
    }

    // Check if user is the review author
    if (review.customer.toString() !== req.user.id) {
      return res.status(403).json({ success: false, error: 'Not authorized to update this review' });
    }

    const { rating, comment } = req.body;

    review = await Review.findByIdAndUpdate(
      req.params.id,
      { rating, comment },
      { new: true, runValidators: true }
    ).populate('customer', 'name profileImage');

    res.status(200).json({
      success: true,
      data: review
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete review
// @route   DELETE /api/reviews/:id
// @access  Private
exports.deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({ success: false, error: 'Review not found' });
    }

    // Check if user is the review author or admin
    if (review.customer.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, error: 'Not authorized to delete this review' });
    }

    await review.deleteOne();

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    next(err);
  }
};
