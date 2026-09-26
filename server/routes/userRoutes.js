const express = require('express');
const router = express.Router();
const User = require('../models/User');

// @route   PUT /api/users/profile/:id
// @desc    Update user profile details (name, bio, avatarUrl)
router.put('/profile/:id', async (req, res) => {
  try {
    const { name, bio, avatarUrl } = req.body;

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { $set: { name, bio, avatarUrl } },
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