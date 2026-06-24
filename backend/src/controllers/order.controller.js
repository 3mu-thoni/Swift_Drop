const mongoose = require('mongoose');
const Order = require('../models/Order');
const Shop = require('../models/Shop');

exports.createOrder = async (req, res) => {
  try {
    console.log('📦 Order request body:', JSON.stringify(req.body, null, 2));
    console.log('👤 User from token:', req.user);

    const {
      shopId,
      items,
      deliveryAddress,
      deliveryLocation,
      deliveryFee,
      paymentMethod,
      notes,
    } = req.body;

    console.log('Creating order:', {
      shopId,
      itemCount: items?.length,
      deliveryAddress,
    });

    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'items are required' });
    }

    if (!deliveryAddress) {
      return res.status(400).json({ message: 'deliveryAddress is required' });
    }

    // Validate shopId — if empty or invalid, find first shop
    let validShopId;
    if (!shopId || !mongoose.Types.ObjectId.isValid(shopId)) {
      console.log('⚠️ Invalid shopId, finding fallback shop...');
      const shop = await Shop.findOne();
      if (!shop) {
        return res.status(400).json({ message: 'No shops available' });
      }
      validShopId = shop._id;
      console.log('✅ Using fallback shop:', validShopId);
    } else {
      validShopId = shopId;
    }

    const subtotal = items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );
    const total = subtotal + (deliveryFee || 0);

    // Validate product IDs
    const validatedItems = items.map((item) => ({
      product: mongoose.Types.ObjectId.isValid(item.product)
        ? item.product
        : new mongoose.Types.ObjectId(),
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl || '',
    }));

    const order = await Order.create({
      customer: req.user.id,
      shop: validShopId,
      items: validatedItems,
      deliveryAddress,
      deliveryLocation: deliveryLocation || { lat: 0, lng: 0 },
      subtotal,
      deliveryFee: deliveryFee || 0,
      total,
      paymentMethod: paymentMethod || 'cash',
      notes: notes || '',
      statusHistory: [{ status: 'pending', note: 'Order placed' }],
    });

    console.log('✅ Order created:', order._id);

    const io = req.app.get('io');
    if (io) {
      io.emit('order:new', {
        orderId: order._id,
        shopId: validShopId,
      });
    }

    res.status(201).json(order);
  } catch (error) {
    console.error('❌ Create order error:', error.message);
    console.error(error.stack);
    res.status(500).json({ message: error.message });
  }
};

exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customer: req.user.id })
      .populate('shop', 'name imageUrl')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    console.error('getMyOrders error:', error.message);
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('shop', 'name imageUrl address')
      .populate('rider', 'name phone photoUrl');
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    console.error('getOrderById error:', error.message);
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status, note } = req.body;
    const order = await Order.findById(req.params.id)
      .populate('customer', 'name fcmToken');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    order.status = status;
    order.statusHistory.push({ status, note: note || '' });
    await order.save();

    // Send push notification
    const { sendNotification } = require('../services/notification.service');
    const statusMessages = {
      confirmed: 'Your order has been confirmed!',
      preparing: 'Your order is being prepared.',
      on_the_way: 'Your order is on the way!',
      delivered: 'Your order has been delivered. Enjoy!',
      cancelled: 'Your order has been cancelled.',
    };

    if (order.customer?.fcmToken && statusMessages[status]) {
      await sendNotification({
        token: order.customer.fcmToken,
        title: 'SwiftDrop Order Update',
        body: statusMessages[status],
        data: { orderId: order._id.toString(), status },
      });
    }

    // Socket notification
    const io = req.app.get('io');
    if (io) {
      io.to(`order:${order._id}`).emit('status:update', {
        orderId: order._id,
        status,
      });
    }

    res.json(order);
  } catch (error) {
    console.error('updateOrderStatus error:', error.message);
    res.status(500).json({ message: error.message });
  }
};