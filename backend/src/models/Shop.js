const mongoose = require('mongoose');

const shopSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    category: {
      type: String,
      enum: ['Food', 'Groceries', 'Pharmacy', 'Electronics', 'Fashion', 'Drinks'],
      required: true,
    },
    owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    address: { type: String, default: '' },
    location: {
      lat: { type: Number, default: -1.286389 },
      lng: { type: Number, default: 36.817223 },
    },
    rating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    deliveryTime: { type: String, default: '30-45 min' },
    deliveryFee: { type: Number, default: 0 },
    isOpen: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Shop', shopSchema);