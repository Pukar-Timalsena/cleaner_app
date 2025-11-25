const express = require('express');
const {
  getServices,
  getService,
  createService,
  updateService,
  deleteService,
  getServiceReviews,
  seedServices
} = require('../controllers/services');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/seed', seedServices);

router.route('/')
  .get(getServices)
  .post(protect, authorize('admin'), createService);

router.route('/:id')
  .get(getService)
  .put(protect, authorize('admin'), updateService)
  .delete(protect, authorize('admin'), deleteService);

router.get('/:id/reviews', getServiceReviews);

module.exports = router;
