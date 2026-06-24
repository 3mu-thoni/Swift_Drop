const router = require('express').Router();
const {
  createProduct,
  updateProduct,
  deleteProduct,
  getAllProducts,
} = require('../controllers/shop.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// Public
router.get('/', getAllProducts);

// Admin only
router.post('/', protect, authorize('admin'), createProduct);
router.put('/:id', protect, authorize('admin'), updateProduct);
router.patch('/:id', protect, authorize('admin'), updateProduct);
router.delete('/:id', protect, authorize('admin'), deleteProduct);

module.exports = router;