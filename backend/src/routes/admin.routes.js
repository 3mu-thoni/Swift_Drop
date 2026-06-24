const router = require('express').Router();
const {
  getDashboard,
  getAllUsers,
  toggleUserStatus,
  getAnalytics,
} = require('../controllers/admin.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.get('/dashboard', protect, authorize('admin'), getDashboard);
router.get('/users', protect, authorize('admin'), getAllUsers);
router.patch(
  '/users/:id/toggle',
  protect,
  authorize('admin'),
  toggleUserStatus
);
router.get('/analytics', protect, authorize('admin'), getAnalytics);

module.exports = router;