const Booking = require('../models/Booking');
const Task = require('../models/Task');

// @desc    Get all bookings
// @route   GET /api/bookings
// @access  Private
exports.getBookings = async (req, res, next) => {
  try {
    let query = {};

    // Customers can only see their own bookings
    if (req.user.role === 'customer') {
      query.customer = req.user.id;
    }

    // Cleaners can only see their assigned bookings
    if (req.user.role === 'cleaner') {
      query.cleaner = req.user.id;
    }

    // Filter by status if provided
    if (req.query.status) {
      query.status = req.query.status;
    }

    const bookings = await Booking.find(query)
      .populate('service', 'title image basePrice category')
      .populate('customer', 'name phone email')
      .populate('cleaner', 'name phone rating')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single booking
// @route   GET /api/bookings/:id
// @access  Private
exports.getBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('service', 'title image basePrice category description')
      .populate('customer', 'name phone email address')
      .populate('cleaner', 'name phone email rating experience');

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found' });
    }

    // Check authorization
    if (
      req.user.role === 'customer' && booking.customer._id.toString() !== req.user.id ||
      req.user.role === 'cleaner' && (!booking.cleaner || booking.cleaner._id.toString() !== req.user.id)
    ) {
      if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, error: 'Not authorized to view this booking' });
      }
    }

    res.status(200).json({
      success: true,
      data: booking
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Create new booking
// @route   POST /api/bookings
// @access  Private
exports.createBooking = async (req, res, next) => {
  try {
    // Add customer ID from logged in user
    req.body.customer = req.user.id;
    req.body.customerName = req.user.name;

    // Set default values if not provided
    if (!req.body.phone) req.body.phone = req.user.phone;
    if (!req.body.address) req.body.address = req.user.address;

    const booking = await Booking.create(req.body);

    const populatedBooking = await Booking.findById(booking._id)
      .populate('service', 'title image basePrice')
      .populate('customer', 'name phone email');

    res.status(201).json({
      success: true,
      data: populatedBooking
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update booking
// @route   PUT /api/bookings/:id
// @access  Private
exports.updateBooking = async (req, res, next) => {
  try {
    let booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found' });
    }

    // Check authorization
    if (req.user.role === 'customer' && booking.customer.toString() !== req.user.id) {
      if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, error: 'Not authorized to update this booking' });
      }
    }

    // Update booking
    booking = await Booking.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('service', 'title image basePrice')
     .populate('cleaner', 'name phone rating');

    // If status changed to completed, update task status
    if (req.body.status === 'completed') {
      await Task.updateMany(
        { booking: booking._id },
        { status: 'completed', completedAt: new Date() }
      );
    }

    res.status(200).json({
      success: true,
      data: booking
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Cancel booking
// @route   PUT /api/bookings/:id/cancel
// @access  Private
exports.cancelBooking = async (req, res, next) => {
  try {
    let booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found' });
    }

    // Only customer or admin can cancel
    if (req.user.role === 'customer' && booking.customer.toString() !== req.user.id) {
      if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, error: 'Not authorized to cancel this booking' });
      }
    }

    booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status: 'cancelled' },
      { new: true }
    ).populate('service', 'title image basePrice');

    // Cancel associated tasks
    await Task.updateMany(
      { booking: booking._id },
      { status: 'cancelled' }
    );

    res.status(200).json({
      success: true,
      data: booking
    });
  } catch (err) {
    next(err);
  }
};
