const express = require('express');
const {
  createReview,
  getReview,
  updateReview,
  deleteReview
} = require('../controllers/reviews');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(createReview);

router.route('/:id')
  .get(getReview)
  .put(updateReview)
  .delete(deleteReview);

module.exports = router;
