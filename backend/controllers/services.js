const Service = require('../models/Service');
const Review = require('../models/Review');

// @desc    Get all services
// @route   GET /api/services
// @access  Public
exports.getServices = async (req, res, next) => {
  try {
    const { category, search, isActive } = req.query;

    let query = {};

    if (category) {
      query.category = category;
    }

    if (search) {
      query.title = { $regex: search, $options: 'i' };
    }

    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    } else {
      query.isActive = true; // Only show active services by default
    }

    const services = await Service.find(query).sort('-createdAt');

    res.status(200).json({
      success: true,
      count: services.length,
      data: services
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single service
// @route   GET /api/services/:id
// @access  Public
exports.getService = async (req, res, next) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({ success: false, error: 'Service not found' });
    }

    res.status(200).json({
      success: true,
      data: service
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Create new service
// @route   POST /api/services
// @access  Private/Admin
exports.createService = async (req, res, next) => {
  try {
    const service = await Service.create(req.body);

    res.status(201).json({
      success: true,
      data: service
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update service
// @route   PUT /api/services/:id
// @access  Private/Admin
exports.updateService = async (req, res, next) => {
  try {
    const service = await Service.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!service) {
      return res.status(404).json({ success: false, error: 'Service not found' });
    }

    res.status(200).json({
      success: true,
      data: service
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete service
// @route   DELETE /api/services/:id
// @access  Private/Admin
exports.deleteService = async (req, res, next) => {
  try {
    const service = await Service.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );

    if (!service) {
      return res.status(404).json({ success: false, error: 'Service not found' });
    }

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get service reviews
// @route   GET /api/services/:id/reviews
// @access  Public
exports.getServiceReviews = async (req, res, next) => {
  try {
    const reviews = await Review.find({ service: req.params.id })
      .populate('customer', 'name profileImage')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      count: reviews.length,
      data: reviews
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Seed services if collection is empty
// @route   POST /api/services/seed
// @access  Public
exports.seedServices = async (req, res, next) => {
  try {
    const count = await Service.countDocuments();

    if (count > 0) {
      return res.status(200).json({
        success: true,
        message: 'Services already exist',
        seeded: false
      });
    }

    const services = [
      {
        title: 'House Cleaning',
        description: 'Professional house cleaning service to keep your home spotless and fresh.',
        category: 'house-cleaning',
        image: 'assets/cleaning.jpg',
        basePrice: 1500,
        rating: 4.4,
        reviewCount: 10,
        location: 'Kathmandu, Nepal',
        isActive: true
      },
      {
        title: 'House Painting',
        description: 'Expert house painting service for interior and exterior walls.',
        category: 'house-painting',
        image: 'assets/house.jpg',
        basePrice: 1500,
        rating: 4.4,
        reviewCount: 10,
        location: 'Kathmandu, Nepal',
        isActive: true
      },
      {
        title: 'Carpet Cleaning',
        description: 'Deep carpet cleaning to remove stains, dirt, and allergens.',
        category: 'carpet-cleaning',
        image: 'assets/carpet.jpg',
        basePrice: 1500,
        rating: 4.4,
        reviewCount: 10,
        location: 'Kathmandu, Nepal',
        isActive: true
      },
      {
        title: 'Sanitary Cleaning',
        description: 'Thorough sanitary and bathroom cleaning for a hygienic environment.',
        category: 'sanitary-cleaning',
        image: 'assets/drapery.jpg',
        basePrice: 1500,
        rating: 4.4,
        reviewCount: 10,
        location: 'Kathmandu, Nepal',
        isActive: true
      }
    ];

    await Service.insertMany(services);

    res.status(201).json({
      success: true,
      message: `Seeded ${services.length} services`,
      seeded: true
    });
  } catch (err) {
    next(err);
  }
};
