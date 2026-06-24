require('dotenv').config();
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGODB_URI).then(async () => {
  try {
    // Skip the User model entirely, insert directly
    const db = mongoose.connection.db;
    const result = await db.collection('users').insertOne({
      name: 'Megg',
      email: 'muthonimegg@gmail.com',
      firebaseUid: '',
      photoUrl: '',
      role: 'customer',
      isActive: true,
      phone: '',
      address: '',
      fcmToken: '',
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log('✅ User created:', result.insertedId);
  } catch (e) {
    console.log('❌ Error:', e.message);
    console.log(e.stack);
  }
  process.exit(0);
});