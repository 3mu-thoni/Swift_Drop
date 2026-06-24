require('dotenv').config();
const mongoose = require('mongoose');
const Shop = require('./models/Shop');
const Product = require('./models/Product');

const shops = [
  {
    name: 'Burger Palace',
    description: 'Best burgers in Nairobi',
    category: 'Food',
    imageUrl: '',
    rating: 4.8,
    reviewCount: 240,
    deliveryTime: '20-30 min',
    deliveryFee: 50,
    address: 'Westlands, Nairobi',
    isOpen: true,
  },
  {
    name: 'Fresh Basket',
    description: 'Fresh groceries delivered daily',
    category: 'Groceries',
    imageUrl: '',
    rating: 4.5,
    reviewCount: 180,
    deliveryTime: '30-45 min',
    deliveryFee: 80,
    address: 'Kilimani, Nairobi',
    isOpen: true,
  },
  {
    name: 'MediQuick',
    description: 'Pharmacy and wellness products',
    category: 'Pharmacy',
    imageUrl: '',
    rating: 4.7,
    reviewCount: 95,
    deliveryTime: '15-25 min',
    deliveryFee: 30,
    address: 'CBD, Nairobi',
    isOpen: true,
  },
  {
    name: 'Pizza Hub',
    description: 'Wood-fired authentic pizzas',
    category: 'Food',
    imageUrl: '',
    rating: 4.6,
    reviewCount: 312,
    deliveryTime: '25-35 min',
    deliveryFee: 60,
    address: 'Karen, Nairobi',
    isOpen: true,
  },
];

const seedDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    await Shop.deleteMany({});
    await Product.deleteMany({});
    console.log('Cleared existing data');

    const createdShops = await Shop.insertMany(shops);
    console.log(`Created ${createdShops.length} shops`);

    const products = [
      {
        name: 'Chicken Burger',
        description: 'Crispy chicken with fresh veggies and secret sauce',
        price: 450,
        category: 'Food',
        shop: createdShops[0]._id,
        rating: 4.9,
        reviewCount: 120,
      },
      {
        name: 'Beef Burger',
        description: 'Juicy beef patty with cheese and lettuce',
        price: 520,
        category: 'Food',
        shop: createdShops[0]._id,
        rating: 4.8,
        reviewCount: 95,
      },
      {
        name: 'Fresh Milk 1L',
        description: 'Farm fresh whole milk',
        price: 80,
        category: 'Groceries',
        shop: createdShops[1]._id,
        rating: 4.5,
        reviewCount: 60,
      },
      {
        name: 'Bread Loaf',
        description: 'Freshly baked white bread',
        price: 55,
        category: 'Groceries',
        shop: createdShops[1]._id,
        rating: 4.3,
        reviewCount: 45,
      },
      {
        name: 'Vitamin C 1000mg',
        description: 'Immune support supplement, 30 tablets',
        price: 350,
        category: 'Pharmacy',
        shop: createdShops[2]._id,
        rating: 4.8,
        reviewCount: 40,
      },
      {
        name: 'Paracetamol 500mg',
        description: 'Pain and fever relief, 24 tablets',
        price: 45,
        category: 'Pharmacy',
        shop: createdShops[2]._id,
        rating: 4.9,
        reviewCount: 200,
      },
      {
        name: 'Margherita Pizza',
        description: 'Classic tomato base with mozzarella',
        price: 680,
        category: 'Food',
        shop: createdShops[3]._id,
        rating: 4.7,
        reviewCount: 150,
      },
      {
        name: 'Pepperoni Pizza',
        description: 'Loaded with pepperoni and mozzarella',
        price: 850,
        category: 'Food',
        shop: createdShops[3]._id,
        rating: 4.8,
        reviewCount: 180,
      },
    ];

    await Product.insertMany(products);
    console.log(`Created ${products.length} products`);

    console.log('✅ Database seeded successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
};

seedDB();