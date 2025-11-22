const User = require('../models/User');
const Service = require('../models/Service');
const Booking = require('../models/Booking');
const Task = require('../models/Task');

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard
// @access  Private/Admin
exports.getDashboardStats = async (req, res, next) => {
  try {
    const totalUsers = await User.countDocuments({ role: 'customer', isActive: true });
    const totalCleaners = await User.countDocuments({ role: 'cleaner', isActive: true });
    const totalServices = await Service.countDocuments({ isActive: true });
    const activeBookings = await Booking.countDocuments({
      status: { $in: ['pending', 'assigned', 'in_progress'] }
    });
    const completedBookings = await Booking.countDocuments({ status: 'completed' });

    // Calculate total revenue from completed bookings
    const revenueData = await Booking.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, totalRevenue: { $sum: '$total' } } }
    ]);

    const totalRevenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalCleaners,
        totalServices,
        activeBookings,
        completedBookings,
        totalRevenue
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all bookings (admin view)
// @route   GET /api/admin/bookings
// @access  Private/Admin
exports.getAllBookings = async (req, res, next) => {
  try {
    const { status, startDate, endDate } = req.query;

    let query = {};

    if (status) {
      query.status = status;
    }

    if (startDate && endDate) {
      query.bookingDate = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }

    const bookings = await Booking.find(query)
      .populate('service', 'title image basePrice')
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

// @desc    Assign cleaner to booking
// @route   PUT /api/admin/bookings/:id/assign
// @access  Private/Admin
exports.assignCleaner = async (req, res, next) => {
  try {
    const { cleanerId } = req.body;

    if (!cleanerId) {
      return res.status(400).json({ success: false, error: 'Please provide a cleaner ID' });
    }

    // Verify cleaner exists and has cleaner role
    const cleaner = await User.findById(cleanerId);
    if (!cleaner || cleaner.role !== 'cleaner') {
      return res.status(400).json({ success: false, error: 'Invalid cleaner ID' });
    }

    // Update booking
    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      {
        cleaner: cleanerId,
        status: 'assigned'
      },
      { new: true }
    ).populate('service', 'title image basePrice')
     .populate('customer', 'name phone email')
     .populate('cleaner', 'name phone rating experience');

    if (!booking) {
      return res.status(404).json({ success: false, error: 'Booking not found' });
    }

    // Create task for the cleaner
    await Task.create({
      booking: booking._id,
      cleaner: cleanerId,
      title: booking.service.title,
      description: `Booking ID: ${booking.bookingId}`,
      location: booking.location,
      status: 'pending',
      priority: 'medium'
    });

    // Increment cleaner's total jobs
    await User.findByIdAndUpdate(cleanerId, {
      $inc: { totalJobs: 1 }
    });

    res.status(200).json({
      success: true,
      data: booking
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private/Admin
exports.getAllUsers = async (req, res, next) => {
  try {
    const { role, isActive } = req.query;

    let query = {};

    if (role) {
      query.role = role;
    }

    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    const users = await User.find(query).sort('-createdAt');

    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all cleaners
// @route   GET /api/admin/cleaners
// @access  Private/Admin
exports.getAllCleaners = async (req, res, next) => {
  try {
    const cleaners = await User.find({ role: 'cleaner', isActive: true })
      .sort('-rating');

    res.status(200).json({
      success: true,
      count: cleaners.length,
      data: cleaners
    });
  } catch (err) {
    next(err);
  }
};
