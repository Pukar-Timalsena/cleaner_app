const Task = require('../models/Task');
const Booking = require('../models/Booking');
const User = require('../models/User');
const Review = require('../models/Review');

// @desc    Get cleaner tasks
// @route   GET /api/cleaners/:id/tasks
// @access  Private
exports.getCleanerTasks = async (req, res, next) => {
  try {
    // Only allow cleaner to see their own tasks or admin can see anyone's
    if (req.params.id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, error: 'Not authorized to view these tasks' });
    }

    const { status } = req.query;

    let query = { cleaner: req.params.id };

    if (status) {
      query.status = status;
    }

    const tasks = await Task.find(query)
      .populate('booking', 'bookingId bookingDate bookingTime customerName phone paymentMethod total')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      count: tasks.length,
      data: tasks
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update task status
// @route   PUT /api/cleaners/:id/tasks/:taskId/status
// @access  Private
exports.updateTaskStatus = async (req, res, next) => {
  try {
    // Only allow cleaner to update their own tasks or admin
    if (req.params.id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, error: 'Not authorized to update this task' });
    }

    const { status } = req.body;

    if (!status || !['pending', 'ongoing', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({ success: false, error: 'Invalid status' });
    }

    const task = await Task.findByIdAndUpdate(
      req.params.taskId,
      { status },
      { new: true, runValidators: true }
    ).populate('booking', 'bookingId bookingDate bookingTime customerName phone');

    if (!task) {
      return res.status(404).json({ success: false, error: 'Task not found' });
    }

    // Update booking status based on task status
    let bookingStatus = 'assigned';
    if (status === 'ongoing') {
      bookingStatus = 'in_progress';
    } else if (status === 'completed') {
      bookingStatus = 'completed';
      await Booking.findByIdAndUpdate(task.booking._id, {
        status: 'completed',
        completedAt: new Date()
      });
    } else if (status === 'cancelled') {
      bookingStatus = 'cancelled';
    }

    if (status !== 'pending') {
      await Booking.findByIdAndUpdate(task.booking._id, { status: bookingStatus });
    }

    res.status(200).json({
      success: true,
      data: task
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get cleaner activity history
// @route   GET /api/cleaners/:id/history
// @access  Private
exports.getCleanerHistory = async (req, res, next) => {
  try {
    // Only allow cleaner to see their own history or admin
    if (req.params.id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, error: 'Not authorized to view this history' });
    }

    const tasks = await Task.find({
      cleaner: req.params.id,
      status: { $in: ['completed', 'cancelled'] }
    })
      .populate('booking', 'bookingId bookingDate customerName total')
      .sort('-completedAt');

    // Get reviews for completed tasks
    const completedTasks = await Task.find({
      cleaner: req.params.id,
      status: 'completed'
    }).select('booking');

    const bookingIds = completedTasks.map(t => t.booking);

    const reviews = await Review.find({
      booking: { $in: bookingIds }
    }).populate('booking', 'bookingId');

    // Map reviews to tasks
    const tasksWithReviews = tasks.map(task => {
      const review = reviews.find(r => r.booking._id.toString() === task.booking._id.toString());
      return {
        ...task.toObject(),
        review: review ? { rating: review.rating, comment: review.comment } : null
      };
    });

    res.status(200).json({
      success: true,
      count: tasksWithReviews.length,
      data: tasksWithReviews
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get cleaner profile with stats
// @route   GET /api/cleaners/:id/profile
// @access  Private
exports.getCleanerProfile = async (req, res, next) => {
  try {
    const cleaner = await User.findById(req.params.id);

    if (!cleaner || cleaner.role !== 'cleaner') {
      return res.status(404).json({ success: false, error: 'Cleaner not found' });
    }

    // Get task statistics
    const totalTasks = await Task.countDocuments({ cleaner: req.params.id });
    const completedTasks = await Task.countDocuments({
      cleaner: req.params.id,
      status: 'completed'
    });
    const ongoingTasks = await Task.countDocuments({
      cleaner: req.params.id,
      status: { $in: ['pending', 'ongoing'] }
    });

    res.status(200).json({
      success: true,
      data: {
        ...cleaner.toObject(),
        stats: {
          totalTasks,
          completedTasks,
          ongoingTasks
        }
      }
    });
  } catch (err) {
    next(err);
  }
};
