const router = require('express').Router();
const Order = require('../models/Order');
const { protect, authorize } = require('../middleware/auth.middleware');

// Get available orders for rider
router.get('/orders', protect, authorize('rider'), async (req, res) => {
  try {
    const orders = await Order.find({ status: 'confirmed', rider: null })
      .populate('shop', 'name address')
      .populate('customer', 'name phone')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Rider accepts an order
router.patch('/orders/:id/accept', protect, authorize('rider'), async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      {
        rider: req.user.id,
        status: 'on_the_way',
        $push: {
          statusHistory: { status: 'on_the_way', note: 'Rider assigned' },
        },
      },
      { new: true }
    );
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get rider's active orders
router.get('/my-orders', protect, authorize('rider'), async (req, res) => {
  try {
    const orders = await Order.find({
      rider: req.user.id,
      status: { $in: ['on_the_way', 'confirmed'] },
    })
      .populate('shop', 'name address')
      .populate('customer', 'name phone address');
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;