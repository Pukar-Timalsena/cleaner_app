const express = require('express');
const {
  getUser,
  updateUser,
  deleteUser,
  getUserBookings
} = require('../controllers/users');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect); // All routes require authentication

router.route('/:id')
  .get(getUser)
  .put(updateUser)
  .delete(deleteUser);

router.get('/:id/bookings', getUserBookings);

module.exports = router;
