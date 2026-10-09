const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const mongoose = require('mongoose');
const User = require('../models/User');

// Ensure destination folder exists
const uploadsDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage for uploaded images
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Preflight OPTIONS handler
router.options('/profile/:identifier', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, PUT, POST, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  return res.sendStatus(200);
});

// @route   PUT /api/users/profile/:identifier
// @desc    Update user profile details
router.put('/profile/:identifier', upload.single('avatar'), async (req, res) => {
  try {
    const { identifier } = req.params;
    const { name, bio, age, height, weight, gender } = req.body;

    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (bio !== undefined) updateFields.bio = bio;
    if (age !== undefined) updateFields.age = age;
    if (height !== undefined) updateFields.height = height;
    if (weight !== undefined) updateFields.weight = weight;
    if (gender !== undefined) updateFields.gender = gender;

    if (req.file) {
      const host = req.get('host') || 'localhost:5000';
      const protocol = req.protocol || 'http';
      updateFields.avatarUrl = `${protocol}://${host}/uploads/${req.file.filename}`;
    }

    // Support lookup by MongoDB ObjectId OR case-insensitive email
    const query = mongoose.Types.ObjectId.isValid(identifier)
      ? { _id: identifier }
      : { email: new RegExp(`^${identifier.trim()}$`, 'i') };

    const updatedUser = await User.findOneAndUpdate(
      query,
      { $set: updateFields },
      { returnDocument: 'after', runValidators: true }
    );

    if (!updatedUser) {
      console.log(`[USER UPDATE ERROR] No user found matching: ${identifier}`);
      return res.status(404).json({
        success: false,
        message: `User not found for identifier: ${identifier}`,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser,
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;