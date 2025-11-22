const express = require('express');
const {
  getDashboardStats,
  getAllBookings,
  assignCleaner,
  getAllUsers,
  getAllCleaners
} = require('../controllers/admin');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(authorize('admin'));

router.get('/dashboard', getDashboardStats);
router.get('/bookings', getAllBookings);
router.put('/bookings/:id/assign', assignCleaner);
router.get('/users', getAllUsers);
router.get('/cleaners', getAllCleaners);

module.exports = router;
