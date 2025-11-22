const express = require('express');
const {
  getCleanerTasks,
  updateTaskStatus,
  getCleanerHistory,
  getCleanerProfile
} = require('../controllers/cleaners');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.use(protect);

router.get('/:id/tasks', getCleanerTasks);
router.put('/:id/tasks/:taskId/status', updateTaskStatus);
router.get('/:id/history', getCleanerHistory);
router.get('/:id/profile', getCleanerProfile);

module.exports = router;
