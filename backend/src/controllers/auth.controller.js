const jwt = require('jsonwebtoken');
const User = require('../models/User');

const generateToken = (user) => {
  return jwt.sign(
    { id: user._id, role: user.role, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

exports.register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    console.log('Register request:', { email, role });

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email and password are required' });
    }

    const exists = await User.findOne({ email });
    if (exists) {
      // If user exists, just return a token
      const token = generateToken(exists);
      return res.json({
        token,
        user: {
          id: exists._id,
          name: exists.name,
          email: exists.email,
          role: exists.role,
          photoUrl: exists.photoUrl,
        },
      });
    }

    const user = await User.create({
      name,
      email,
      password,
      role: role || 'customer',
    });

    const token = generateToken(user);

    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        photoUrl: user.photoUrl,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('Login attempt:', email);

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // If user has no password (registered via Google/Firebase)
    // create a token directly
    if (!user.password) {
      const token = generateToken(user);
      return res.json({
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          photoUrl: user.photoUrl,
        },
      });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        photoUrl: user.photoUrl,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: error.message });
  }
};

exports.googleAuth = async (req, res) => {
  try {
    const { firebaseUid, email, name, photoUrl, role } = req.body;
    console.log('Google auth attempt:', { email, name });

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    let user = await User.findOne({ email });

    if (!user) {
      user = await User.create({
        name: name || 'User',
        email: email,
        firebaseUid: firebaseUid || '',
        photoUrl: photoUrl || '',
        role: role || 'customer',
        password: undefined,
      });
      console.log('✅ New user created:', user._id);
    } else {
      if (firebaseUid) user.firebaseUid = firebaseUid;
      if (photoUrl) user.photoUrl = photoUrl;
      await user.save();
      console.log('✅ Existing user updated:', user._id);
    }

    const token = generateToken(user);
    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        photoUrl: user.photoUrl,
      },
    });
  } catch (error) {
    console.error('❌ Google auth error:', error.message);
    console.error(error.stack);
    return res.status(500).json({ message: error.message });
  }
};

exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};