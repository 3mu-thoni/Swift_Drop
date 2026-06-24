const router = require('express').Router();
const {
  register, login, googleAuth, getMe,
} = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleAuth);
router.get('/me', protect, getMe);
router.patch('/fcm-token', protect, async (req, res) => {
  try {
    const User = require('../models/User');
    await User.findByIdAndUpdate(req.user.id, {
      fcmToken: req.body.fcmToken,
    });
    res.json({ message: 'FCM token updated' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.patch('/profile', protect, async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { ...req.body },
      { new: true }
    ).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;