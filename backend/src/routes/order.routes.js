const router = require('express').Router();
const {
  createOrder,
  getMyOrders,
  getOrderById,
  updateOrderStatus,
} = require('../controllers/order.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.post('/', protect, createOrder);
router.get('/my', protect, getMyOrders);
router.get('/:id', protect, getOrderById);
router.patch('/:id/status', protect, authorize('admin', 'rider'), updateOrderStatus);

module.exports = router;