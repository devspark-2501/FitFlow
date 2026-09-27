const express = require('express');
const router = express.Router();
const User = require('../models/User');

// @route   PUT /api/users/profile/:id
// @desc    Update user profile details and metrics
router.put('/profile/:id', async (req, res) => {
  try {
    const { name, bio, avatarUrl, age, height, weight, gender } = req.body;

    // Build update object with provided fields
    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (bio !== undefined) updateFields.bio = bio;
    if (avatarUrl !== undefined) updateFields.avatarUrl = avatarUrl;
    if (age !== undefined) updateFields.age = age;
    if (height !== undefined) updateFields.height = height;
    if (weight !== undefined) updateFields.weight = weight;
    if (gender !== undefined) updateFields.gender = gender;

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { $set: updateFields },
      { new: true, runValidators: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;