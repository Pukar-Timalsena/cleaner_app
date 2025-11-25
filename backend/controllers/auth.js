const { validationResult } = require('express-validator');
const User = require('../models/User');

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { name, email, password, phone, address, role, experience } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, error: 'User already exists' });
    }

    // Create user
    const user = await User.create({
      name,
      email,
      password,
      phone,
      address,
      role: role || 'customer',
      experience: role === 'cleaner' ? experience : null
    });

    sendTokenResponse(user, 201, res);
  } catch (err) {
    next(err);
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email, password } = req.body;

    // Check for user
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    // Check if password matches
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({ success: false, error: 'Account is deactivated' });
    }

    sendTokenResponse(user, 200, res);
  } catch (err) {
    next(err);
  }
};

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Public
exports.logout = async (req, res, next) => {
  res.status(200).json({
    success: true,
    data: {}
  });
};

// @desc    Seed test accounts if they don't exist
// @route   POST /api/auth/seed-test-accounts
// @access  Public
exports.seedTestAccounts = async (req, res, next) => {
  try {
    const testAccounts = [
      {
        name: 'Test Customer',
        email: 'user@test.com',
        password: 'user123',
        phone: '9800000001',
        address: 'Kathmandu, Nepal',
        role: 'customer'
      },
      {
        name: 'Test Admin',
        email: 'admin@test.com',
        password: 'admin123',
        phone: '9800000002',
        address: 'Kathmandu, Nepal',
        role: 'admin'
      },
      {
        name: 'Test Cleaner',
        email: 'cleaner@test.com',
        password: 'cleaner123',
        phone: '9800000003',
        address: 'Kathmandu, Nepal',
        role: 'cleaner',
        experience: 3,
        rating: 4.5,
        totalJobs: 25
      }
    ];

    const createdAccounts = [];

    for (const account of testAccounts) {
      const existingUser = await User.findOne({ email: account.email });
      if (!existingUser) {
        await User.create(account);
        createdAccounts.push(account.email);
      }
    }

    res.status(200).json({
      success: true,
      message: createdAccounts.length > 0
        ? `Created ${createdAccounts.length} test account(s)`
        : 'All test accounts already exist',
      created: createdAccounts
    });
  } catch (err) {
    next(err);
  }
};

// Helper function to get token from model, create cookie and send response
const sendTokenResponse = (user, statusCode, res) => {
  const token = user.getSignedJwtToken();

  res.status(statusCode).json({
    success: true,
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.address,
      role: user.role,
      rating: user.rating,
      totalJobs: user.totalJobs,
      experience: user.experience
    }
  });
};
