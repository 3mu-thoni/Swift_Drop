const User = require('../models/User');
const Order = require('../models/Order');
const Shop = require('../models/Shop');

exports.getDashboard = async (req, res) => {
  try {
    const [
      totalUsers, totalOrders, totalShops,
      pendingOrders, deliveredOrders,
    ] = await Promise.all([
      User.countDocuments(),
      Order.countDocuments(),
      Shop.countDocuments(),
      Order.countDocuments({ status: 'pending' }),
      Order.countDocuments({ status: 'delivered' }),
    ]);

    const revenueResult = await Order.aggregate([
      { $match: { status: 'delivered' } },
      { $group: { _id: null, total: { $sum: '$total' } } },
    ]);

    const revenue = revenueResult[0]?.total || 0;

    const recentOrders = await Order.find()
      .populate('customer', 'name email')
      .populate('shop', 'name')
      .sort({ createdAt: -1 })
      .limit(10);

    res.json({
      stats: {
        totalUsers, totalOrders, totalShops,
        pendingOrders, deliveredOrders, revenue,
      },
      recentOrders,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    user.isActive = !user.isActive;
    await user.save();
    res.json({ message: `User ${user.isActive ? 'activated' : 'deactivated'}` });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAnalytics = async (req, res) => {
  try {
    // Orders per day for last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const ordersPerDay = await Order.aggregate([
      { $match: { createdAt: { $gte: sevenDaysAgo } } },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt',
            },
          },
          count: { $sum: 1 },
          revenue: { $sum: '$total' },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Orders by status
    const ordersByStatus = await Order.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    // Orders by payment method
    const ordersByPayment = await Order.aggregate([
      {
        $group: {
          _id: '$paymentMethod',
          count: { $sum: 1 },
        },
      },
    ]);

    // Top shops by order count
    const topShops = await Order.aggregate([
      {
        $group: {
          _id: '$shop',
          orderCount: { $sum: 1 },
          revenue: { $sum: '$total' },
        },
      },
      { $sort: { orderCount: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: 'shops',
          localField: '_id',
          foreignField: '_id',
          as: 'shop',
        },
      },
      { $unwind: '$shop' },
      {
        $project: {
          name: '$shop.name',
          orderCount: 1,
          revenue: 1,
        },
      },
    ]);

    // Users by role
    const usersByRole = await User.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 },
        },
      },
    ]);

    res.json({
      ordersPerDay,
      ordersByStatus,
      ordersByPayment,
      topShops,
      usersByRole,
    });
  } catch (error) {
    console.error('Analytics error:', error.message);
    res.status(500).json({ message: error.message });
  }
};

