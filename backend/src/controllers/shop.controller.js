const Shop = require('../models/Shop');
const Product = require('../models/Product');

exports.getAllShops = async (req, res) => {
  try {
    const { category, search, page = 1, limit = 20 } = req.query;
    const query = { isActive: true };

    if (category && category !== 'All') query.category = category;
    if (search) query.name = { $regex: search, $options: 'i' };

    const shops = await Shop.find(query)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ rating: -1 });

    res.json({ shops, page, total: shops.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getShopById = async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.id);
    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    res.json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getShopProducts = async (req, res) => {
  try {
    const products = await Product.find({
      shop: req.params.id,
      isAvailable: true,
    });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createShop = async (req, res) => {
  try {
    const shop = await Shop.create({ ...req.body });
    res.status(201).json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateShop = async (req, res) => {
  try {
    const shop = await Shop.findByIdAndUpdate(
      req.params.id,
      { ...req.body },
      { new: true }
    );
    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    res.json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteShop = async (req, res) => {
  try {
    await Shop.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ message: 'Shop deactivated' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createProduct = async (req, res) => {
  try {
    const product = await Product.create({ ...req.body });
    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      { ...req.body },
      { new: true }
    );
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    await Product.findByIdAndUpdate(req.params.id, {
      isAvailable: false,
    });
    res.json({ message: 'Product deactivated' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllProducts = async (req, res) => {
  try {
    const { category, search, shopId } = req.query;
    const query = {};
    if (category) query.category = category;
    if (shopId) query.shop = shopId;
    if (search) query.name = { $regex: search, $options: 'i' };
    const products = await Product.find(query)
      .populate('shop', 'name')
      .sort({ createdAt: -1 });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};