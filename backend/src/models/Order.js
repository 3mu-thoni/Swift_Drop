const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
  name: String,
  price: Number,
  quantity: Number,
  imageUrl: String,
});

const orderSchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    rider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    shop: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Shop',
      required: true,
    },
    items: [orderItemSchema],
    status: {
      type: String,
      enum: [
        'pending',
        'confirmed',
        'preparing',
        'on_the_way',
        'delivered',
        'cancelled',
      ],
      default: 'pending',
    },
    deliveryAddress: { type: String, required: true },
    deliveryLocation: {
      lat: { type: Number, default: 0 },
      lng: { type: Number, default: 0 },
    },
    subtotal: { type: Number, required: true },
    deliveryFee: { type: Number, default: 0 },
    total: { type: Number, required: true },
    paymentMethod: {
      type: String,
      enum: ['cash', 'mpesa', 'card'],
      default: 'cash',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'failed'],
      default: 'pending',
    },
    mpesaTransactionId: { type: String, default: '' },
    mpesaCheckoutRequestId: { type: String, default: '' },
    notes: { type: String, default: '' },
    statusHistory: [
      {
        status: String,
        timestamp: { type: Date, default: Date.now },
        note: String,
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Order', orderSchema);