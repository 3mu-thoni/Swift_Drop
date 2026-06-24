const router = require('express').Router();
const {
  getAllShops,
  getShopById,
  getShopProducts,
  createShop,
  updateShop,
  deleteShop,
} = require('../controllers/shop.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Public routes
router.get('/', getAllShops);
router.get('/:id', getShopById);
router.get('/:id/products', getShopProducts);

// Admin only
router.post('/', protect, authorize('admin'), createShop);
router.put('/:id', protect, authorize('admin'), updateShop);
router.patch('/:id', protect, authorize('admin'), updateShop);
router.delete('/:id', protect, authorize('admin'), deleteShop);

module.exports = router;