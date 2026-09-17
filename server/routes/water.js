const express = require('express');
const router = express.Router();
const WaterLog = require('../models/WaterLog');

// @route   POST /api/water/add
// @desc    Add a water log entry for a specific user
router.post('/add', async (req, res) => {
  try {
    const { userId, amount, date } = req.body;

    if (!userId || !amount || !date) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const newLog = new WaterLog({ userId, amount, date });
    await newLog.save();

    res.status(201).json({ success: true, log: newLog });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// @route   GET /api/water/:userId/:date
// @desc    Get all water logs and total intake for a user on a specific date
router.get('/:userId/:date', async (req, res) => {
  try {
    const { userId, date } = req.params;

    const logs = await WaterLog.find({ userId, date }).sort({ timestamp: -1 });
    const totalIntake = logs.reduce((sum, item) => sum + item.amount, 0);

    res.status(200).json({
      success: true,
      totalIntake,
      logs,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;