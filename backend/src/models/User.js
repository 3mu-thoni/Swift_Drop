const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      default: null,
    },
    role: {
      type: String,
      enum: ['customer', 'rider', 'admin'],
      default: 'customer',
    },
    photoUrl: { type: String, default: '' },
    phone: { type: String, default: '' },
    address: { type: String, default: '' },
    isActive: { type: Boolean, default: true },
    firebaseUid: { type: String, default: '' },
    fcmToken: { type: String, default: '' },
  },
  { timestamps: true }
);

userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  if (!this.password) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  if (!this.password) return false;
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);