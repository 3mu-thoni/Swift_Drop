const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    price: { type: Number, required: true },
    imageUrl: { type: String, default: '' },
    category: { type: String, required: true },
    shop: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
    rating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    isAvailable: { type: Boolean, default: true },
    stock: { type: Number, default: 100 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Product', productSchema);